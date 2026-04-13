const mysql = require("mysql2");
require("dotenv").config();

const db = mysql.createConnection({
  host: '127.0.0.1',
  port: 3306,
  user: 'root',
  password: 'Polenta10#',
  database: 'diethub',
});

db.connect((err) => {
  if (err) {
    console.error("❌ Erro ao conectar ao banco de dados: " + err.stack);
    return;
  }
  console.log("✅ Conectado ao banco de dados MySQL com o ID " + db.threadId);
});

module.exports = db;