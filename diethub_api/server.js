const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;

// Rota de Registro
app.post("/register", async (req, res) => {
  // 1. Pegamos os dados que o Flutter enviou (nome, cpf, email, password)
  const { nome, cpf, email, password } = req.body;

  // 2. Verificamos se todos os campos chegaram (Segurança!)
  if (!nome || !cpf || !email || !password) {
    return res.status(400).json({ message: "Todos os campos são obrigatórios!" });
  }

  try {
    // 3. Embaralhamos a senha (bcrypt)
    const hashedPassword = await bcrypt.hash(password, 10);

    // 4. Agora sim, salvamos no banco usando o nome correto da tabela e colunas
    const sql = "INSERT INTO user (nome, cpf, email, hash_password) VALUES (?, ?, ?, ?)";
    
    db.query(sql, [nome, cpf, email, hashedPassword], (err, result) => {
      if (err) {
        console.error("Erro ao registrar usuário:", err.message);
        return res.status(500).json({ message: "Erro ao registrar usuário no banco." });
      }
      res.status(201).json({ message: "Usuário registrado com sucesso!" });
    });
  } catch (error) {
    console.error("Erro ao processar registro:", error.message);
    res.status(500).json({ message: "Erro interno do servidor." });
  }
});


// Rota de Login de Usuário
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  const sql = "SELECT * FROM user WHERE email = ?";
  db.query(sql, [email], async (err, results) => {
    if (err) {
      console.error("Erro ao buscar usuário: " + err.message);
      return res.status(500).json({ message: "Erro interno do servidor." });
    }
    if (results.length === 0) {
      return res.status(401).json({ message: "Email ou senha inválidos." });
    }

    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.hash_password);

    if (!isMatch) {
      return res.status(401).json({ message: "Email ou senha inválidos." });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: "1h" }); // Gera um token JWT
    res.status(200).json({ message: "Login bem-sucedido!", token });
  });
});

// Middleware de autenticação (exemplo para rotas protegidas)
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token == null) return res.sendStatus(401); // Não autorizado se não houver token

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403); // Proibido se o token for inválido
    req.user = user;
    next(); // Continua para a próxima função (a rota protegida)
  });
};

// Exemplo de rota protegida
app.get("/profile", authenticateToken, (req, res) => {
  res.json({ message: `Bem-vindo, ${req.user.email}! Este é o seu perfil.` });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});