const express = require('express');
const cors = require('cors');
const axios = require('axios');
const crypto = require('crypto');
const sql = require('mssql');
const path = require('path'); // <-- YENİ SATIR: path modülünü dahil et

const app = express();
// istek yapmasına izin verir.
app.use(cors());

// --- 2. ADIM: STATİK DOSYA SUNUCUSU (Resimler İçin En Önemli Kısım) ---
// Bu satır, 'public' klasörünü dışarıya açmamızı sağlar.
// __dirname, server.js dosyasının bulunduğu klasörün tam yolunu verir.
// Bu sayede sunucuyu nereden çalıştırırsanız çalıştırın, her zaman doğru klasörü bulur.
app.use(express.static(path.join(__dirname, 'public')));


const PORT = 3000;

const sqlConfig = {
    user: 'dashboard',
    password: 'dashboard25',
    server: '172.16.11.1',
    database: 'MERKEZDB',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

// --- GÜNCELLENDİ: Bu endpoint artık dinamik bir ambar numarası alabiliyor ---
app.get('/api/products', async (req, res) => {
    try {
        // 1. Frontend'den gönderilen 'ammarNo' query parametresini alıyoruz.
        // Eğer bir parametre gönderilmezse, varsayılan olarak '90' kullanılacak.
        const ammarNo = req.query.ammarNo || '90'; 

        console.log(`--- /api/products isteği geldi (Ambar No: ${ammarNo}), SQL Server'a bağlanılıyor... ---`);
        
        await sql.connect(sqlConfig);
        const request = new sql.Request();

        // 2. Stored procedure'e parametreyi sabit '90' yerine dinamik olarak alınan 'ammarNo' ile ekliyoruz.
        request.input('AMMARNO', sql.Int, ammarNo);

        const result = await request.execute('WEB_SP_001_GENELSTOK');

        console.log(`${result.recordset.length} adet ürün kaydı (Ambar No: ${ammarNo}) başarıyla çekildi.`);
        console.log('--------------------------------------------------------------------');

        res.json(result.recordset);

    } catch (err) {
        console.error('SQL Server hatası:', err);
        res.status(500).send('Veritabanından veri alınırken bir hata oluştu.');
    } finally {
        await sql.close();
    }
});


// =================================================================
// ===== MEVCUT DAHUA VE PROXY KODUNUZ AŞAĞIDA DEĞİŞTİRİLMEDİ ======
// =================================================================
// ... (geri kalan kodunuz aynı kalacak)
const devices = [
    {
        DAHUA_BASE_URL: 'http://172.16.14.104',
        DAHUA_USERNAME: 'admin',
        DAHUA_PASSWORD: 'yoda12345',
    },
    {
        DAHUA_BASE_URL: 'http://172.16.14.105',
        DAHUA_USERNAME: 'admin',
        DAHUA_PASSWORD: 'admin123',
    }
];

const DAHUA_API_PATH = '/cgi-bin/recordFinder.cgi';

function md5(str) {
    return crypto.createHash('md5').update(str).digest('hex');
}

async function generateDigestAuthHeader(method, uri, wwwAuthenticateHeader, username, password, realm, nonce, qop) {
    const ha1 = md5(`${username}:${realm}:${password}`);
    const ha2 = md5(`${method}:${uri}`);
    const cnonce = md5(Math.random().toString()).substring(0, 16);
    const nc = '00000001';
    const response = md5(`${ha1}:${nonce}:${nc}:${cnonce}:${qop}:${ha2}`);
    return `Digest username="${username}", realm="${realm}", nonce="${nonce}", uri="${uri}", qop="${qop}", nc="${nc}", cnonce="${cnonce}", response="${response}", algorithm=MD5`;
}

async function fetchRecordsFromDevice(device, startTime, endTime) {
    const { DAHUA_BASE_URL, DAHUA_USERNAME, DAHUA_PASSWORD } = device;
    const dahuaApiUrl = `${DAHUA_BASE_URL}${DAHUA_API_PATH}?action=find&name=AccessControlCardRec&StartTime=${startTime}&EndTime=${endTime}`;
    const dahuaUriPath = `${DAHUA_API_PATH}?action=find&name=AccessControlCardRec&StartTime=${startTime}&EndTime=${endTime}`;

    console.log(`İstek gönderiliyor: ${dahuaApiUrl}`);

    try {
        const initialResponse = await axios.get(dahuaApiUrl, { validateStatus: (status) => status === 200 || status === 401 });

        if (initialResponse.status === 401 && initialResponse.headers['www-authenticate']) {
            const wwwAuthHeader = initialResponse.headers['www-authenticate'];
            const realmMatch = /realm="([^"]+)"/.exec(wwwAuthHeader);
            const nonceMatch = /nonce="([^"]+)"/.exec(wwwAuthHeader);
            const qopMatch = /qop="([^"]+)"/.exec(wwwAuthHeader);

            if (!realmMatch || !nonceMatch || !qopMatch) {
                throw new Error('www-authenticate başlığında eksik realm, nonce veya qop.');
            }

            console.log(`Cihazdan ${DAHUA_BASE_URL} alınan www-authenticate başlığı: ${wwwAuthHeader}`);
            const authHeader = await generateDigestAuthHeader('GET', dahuaUriPath, wwwAuthHeader, DAHUA_USERNAME, DAHUA_PASSWORD, realmMatch[1], nonceMatch[1], qopMatch[1]);
            console.log(`Cihaz ${DAHUA_BASE_URL} için oluşturulan Yetkilendirme Başlığı: ${authHeader}`);
            const authenticatedResponse = await axios.get(dahuaApiUrl, { headers: { 'Authorization': authHeader } });
            console.log(`Cihaz ${DAHUA_BASE_URL} için kimliği doğrulanmış yanıt durumu: ${authenticatedResponse.status}`);
            console.log(`Cihazdan ${DAHUA_BASE_URL} alınan veri:`, authenticatedResponse.data);
            return authenticatedResponse.data;
        } else if (initialResponse.status === 200) {
            return initialResponse.data;
        } else {
            console.error(`Cihazdan beklenmeyen durum kodu: ${initialResponse.status}`, device);
            return '';
        }
    } catch (error) {
        console.error(`Cihazdan veri alınırken hata: ${error.message}`, device);
        return '';
    }
}

function parseDahuaResponse(responseText) {
    const records = [];
    if (!responseText) return records;

    const lines = responseText.trim().split('\n');
    const recordMap = {};

    for (const line of lines) {
        const match = line.match(/records\[(\d+)\]\.(\w+)=(.+)/);
        if (match) {
            const index = parseInt(match[1], 10);
            const key = match[2];
            const value = match[3].trim();
            if (!recordMap[index]) {
                recordMap[index] = {};
            }
            recordMap[index][key] = value;
        }
    }

    for (const index in recordMap) {
        records.push(recordMap[index]);
    }
    return records;
}

function formatRecordsToDahuaResponse(records) {
    let responseText = `found=${records.length}\n`;
    records.forEach((record, index) => {
        for (const key in record) {
            responseText += `records[${index}].${key}=${record[key]}\n`;
        }
    });
    return responseText;
}

app.get('/api/records', async (req, res) => {
    const { StartTime, EndTime } = req.query;
    if (!StartTime || !EndTime) {
        return res.status(400).send('StartTime ve EndTime gereklidir.');
    }

    try {
        const promises = devices.map(device => fetchRecordsFromDevice(device, StartTime, EndTime));
        const results = await Promise.all(promises);

        let allRecords = [];
        results.forEach(result => {
            const parsedRecords = parseDahuaResponse(result);
            allRecords = allRecords.concat(parsedRecords);
        });

        const combinedResponse = formatRecordsToDahuaResponse(allRecords);
        res.set('Content-Type', 'text/plain');
        res.send(combinedResponse);

    } catch (error) {
        console.error('Tüm cihazlardan veri alınırken bir hata oluştu:', error);
        res.status(500).send('Cihazlardan veri alınırken bir hata oluştu.');
    }
});


app.listen(PORT, () => {
    console.log(`Proxy sunucu http://localhost:${PORT} üzerinde dinleniyor`);
    console.log(`Statik dosyalar (resimler) şu klasörden sunuluyor: ${path.join(__dirname, 'public')}`);
});