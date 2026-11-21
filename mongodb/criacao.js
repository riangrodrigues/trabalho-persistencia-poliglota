// =============================================================================
// MongoDB — Script de Criação (Requisito R2: Catálogo Polimórfico de Conteúdos)
// Banco: streaming
// Execução: docker exec -i streaming-mongodb mongosh streaming /scripts/mongodb/criacao.js
// =============================================================================

const dbName = "streaming";
const dbRef = db.getSiblingDB(dbName);

print("=== [MongoDB] Criando coleções, validações e índices no banco '" + dbName + "' ===");

// Recria coleções de forma idempotente para permitir reexecução limpa
["avaliacoes", "conteudos", "estudios"].forEach((col) => {
  if (dbRef.getCollectionNames().includes(col)) {
    dbRef[col].drop();
  }
});

// 1. Coleção referenciada: estudios (evita duplicar dados de produtoras em centenas de títulos)
dbRef.createCollection("estudios", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "nome", "pais_origem", "ano_fundacao"],
      properties: {
        _id: { bsonType: "string" },
        nome: { bsonType: "string" },
        pais_origem: { bsonType: "string" },
        ano_fundacao: { bsonType: "int" },
        site: { bsonType: "string" }
      }
    }
  }
});

// 2. Coleção principal polimórfica: conteudos
// Valida o núcleo comum (título, tipo, gêneros, estudio_id), mantendo schema flexível
// para os atributos específicos de filme, serie e documentario (additionalProperties: true).
dbRef.createCollection("conteudos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "titulo", "tipo", "generos", "genero_slugs", "estudio_id", "idiomas_disponiveis"],
      additionalProperties: true,
      properties: {
        _id: { bsonType: "string", description: "UUID compartilhado com PostgreSQL, Redis, Cassandra e Neo4j" },
        titulo: { bsonType: "string" },
        tipo: { enum: ["filme", "serie", "documentario"] },
        sinopse: { bsonType: "string" },
        generos: { bsonType: "array", items: { bsonType: "string" }, minItems: 1 },
        genero_slugs: { bsonType: "array", items: { bsonType: "string" }, minItems: 1 },
        estudio_id: { bsonType: "string", description: "Referência para estudios._id" },
        idiomas_disponiveis: {
          bsonType: "object",
          required: ["audio", "legendas"],
          properties: {
            audio: { bsonType: "array", items: { bsonType: "string" } },
            legendas: { bsonType: "array", items: { bsonType: "string" } }
          }
        }
      }
    }
  }
});

// 3. Coleção referenciada: avaliacoes (crescimento ilimitado -> nunca embutir no documento do conteúdo!)
dbRef.createCollection("avaliacoes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["conteudo_id", "usuario_id", "nota", "criado_em"],
      properties: {
        conteudo_id: { bsonType: "string" },
        usuario_id: { bsonType: "string" },
        nota: { bsonType: "int", minimum: 1, maximum: 5 },
        comentario: { bsonType: "string" },
        criado_em: { bsonType: "date" }
      }
    }
  }
});

// Índices para consultas rápidas do catálogo
dbRef.conteudos.createIndex({ tipo: 1 }, { name: "idx_conteudos_tipo" });
dbRef.conteudos.createIndex({ genero_slugs: 1 }, { name: "idx_conteudos_genero_slugs" }); // Multikey index
dbRef.conteudos.createIndex({ estudio_id: 1 }, { name: "idx_conteudos_estudio" });
dbRef.conteudos.createIndex({ titulo: "text", sinopse: "text" }, { name: "idx_conteudos_busca_texto", default_language: "portuguese" });

dbRef.avaliacoes.createIndex({ conteudo_id: 1, criado_em: -1 }, { name: "idx_avaliacoes_conteudo" });
dbRef.avaliacoes.createIndex({ usuario_id: 1, conteudo_id: 1 }, { unique: true, name: "ux_avaliacao_usuario_conteudo" });

print("Coleções criadas:", dbRef.getCollectionNames().join(", "));
print("Índices em 'conteudos':", dbRef.conteudos.getIndexes().map((i) => i.name).join(", "));
print("=== [MongoDB] Criação concluída com sucesso! ===");
