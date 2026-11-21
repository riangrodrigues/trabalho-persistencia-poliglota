// =============================================================================
// MongoDB — Script de Carga (Requisito R2: Catálogo Polimórfico de Conteúdos)
// Todos os UUIDs seguem estritamente CONTRATO_IDS.md
// Execução: docker exec -i streaming-mongodb mongosh streaming /scripts/mongodb/carga.js
// =============================================================================

const dbRef = db.getSiblingDB("streaming");

print("=== [MongoDB] Iniciando carga de dados do catálogo UniStream ===");

dbRef.avaliacoes.deleteMany({});
dbRef.conteudos.deleteMany({});
dbRef.estudios.deleteMany({});

// 1. Estúdios (REFERENCIADOS por conteudos.estudio_id)
dbRef.estudios.insertMany([
  {
    _id: "33333333-3333-4333-8333-000000000001",
    nome: "Warner Bros. Pictures",
    pais_origem: "Estados Unidos",
    ano_fundacao: NumberInt(1923),
    site: "https://www.warnerbros.com"
  },
  {
    _id: "33333333-3333-4333-8333-000000000002",
    nome: "UniStream Originals",
    pais_origem: "Brasil",
    ano_fundacao: NumberInt(2020),
    site: "https://originals.unistream.com"
  },
  {
    _id: "33333333-3333-4333-8333-000000000003",
    nome: "HBO Entertainment",
    pais_origem: "Estados Unidos",
    ano_fundacao: NumberInt(1972),
    site: "https://www.hbo.com"
  },
  {
    _id: "33333333-3333-4333-8333-000000000004",
    nome: "National Geographic Documentary Films",
    pais_origem: "Estados Unidos",
    ano_fundacao: NumberInt(1997),
    site: "https://films.nationalgeographic.com"
  },
  {
    _id: "33333333-3333-4333-8333-000000000005",
    nome: "Barunson E&A",
    pais_origem: "Coreia do Sul",
    ano_fundacao: NumberInt(1996),
    site: "https://www.barunsonena.com"
  }
]);

// 2. Conteúdos Polimórficos (6 filmes, 5 séries, 4 documentários)
// Repare como cada tipo tem atributos completamente distintos no mesmo catálogo:
// - filme: duracao_minutos, diretor, ano_lancamento, elenco (embutido), premiacoes
// - serie: criador, em_andamento, total_temporadas, temporadas[].episodios[] (embutido)
// - documentario: tema, ano_producao, narrador, formato, fontes_entrevistadas
dbRef.conteudos.insertMany([
  // -------------------- FILMES --------------------
  {
    _id: "22222222-2222-4222-8222-000000000001",
    titulo: "Interestelar",
    tipo: "filme",
    sinopse: "Exploradores viajam através de um buraco de minhoca no espaço em busca de um novo lar para a humanidade.",
    generos: ["Ficção Científica", "Drama"],
    genero_slugs: ["ficcao-cientifica", "drama"],
    estudio_id: "33333333-3333-4333-8333-000000000001",
    idiomas_disponiveis: { audio: ["PT-BR", "EN", "ES"], legendas: ["PT-BR", "EN", "ES"] },
    // Atributos específicos de FILME
    duracao_minutos: NumberInt(169),
    diretor: "Christopher Nolan",
    ano_lancamento: NumberInt(2014),
    classificacao_indicativa: "10+",
    elenco: ["Matthew McConaughey", "Anne Hathaway", "Jessica Chastain"],
    premiacoes: ["Oscar de Melhores Efeitos Visuais"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000002",
    titulo: "A Origem",
    tipo: "filme",
    sinopse: "Um ladrão especializado em extrair segredos do subconsciente recebe a missão inversa: plantar uma ideia.",
    generos: ["Ficção Científica", "Ação"],
    genero_slugs: ["ficcao-cientifica", "acao"],
    estudio_id: "33333333-3333-4333-8333-000000000001",
    idiomas_disponiveis: { audio: ["PT-BR", "EN"], legendas: ["PT-BR", "EN", "FR"] },
    duracao_minutos: NumberInt(148),
    diretor: "Christopher Nolan",
    ano_lancamento: NumberInt(2010),
    classificacao_indicativa: "14+",
    elenco: ["Leonardo DiCaprio", "Joseph Gordon-Levitt", "Elliot Page"],
    premiacoes: ["Oscar de Melhor Fotografia", "Oscar de Melhores Efeitos Visuais"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000003",
    titulo: "Blade Runner 2049",
    tipo: "filme",
    sinopse: "Um jovem caçador de replicantes descobre um segredo enterrado há décadas que ameaça a sociedade.",
    generos: ["Ficção Científica", "Suspense"],
    genero_slugs: ["ficcao-cientifica", "suspense"],
    estudio_id: "33333333-3333-4333-8333-000000000001",
    idiomas_disponiveis: { audio: ["PT-BR", "EN"], legendas: ["PT-BR", "EN"] },
    duracao_minutos: NumberInt(164),
    diretor: "Denis Villeneuve",
    ano_lancamento: NumberInt(2017),
    classificacao_indicativa: "14+",
    elenco: ["Ryan Gosling", "Harrison Ford", "Ana de Armas"],
    premiacoes: ["Oscar de Melhor Fotografia"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000004",
    titulo: "Matrix",
    tipo: "filme",
    sinopse: "Um programador descobre que a realidade em que vive é uma simulação criada por máquinas.",
    generos: ["Ficção Científica", "Ação"],
    genero_slugs: ["ficcao-cientifica", "acao"],
    estudio_id: "33333333-3333-4333-8333-000000000001",
    idiomas_disponiveis: { audio: ["PT-BR", "EN", "ES"], legendas: ["PT-BR", "EN", "ES"] },
    duracao_minutos: NumberInt(136),
    diretor: "Lana e Lilly Wachowski",
    ano_lancamento: NumberInt(1999),
    classificacao_indicativa: "14+",
    elenco: ["Keanu Reeves", "Laurence Fishburne", "Carrie-Anne Moss"],
    premiacoes: ["Oscar de Melhor Montagem", "Oscar de Melhores Efeitos Visuais"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000005",
    titulo: "Parasita",
    tipo: "filme",
    sinopse: "Uma família sem recursos se infiltra gradualmente na rotina de uma família rica em Seul.",
    generos: ["Suspense", "Drama"],
    genero_slugs: ["suspense", "drama"],
    estudio_id: "33333333-3333-4333-8333-000000000005",
    idiomas_disponiveis: { audio: ["KO", "PT-BR"], legendas: ["PT-BR", "EN", "ES"] },
    duracao_minutos: NumberInt(132),
    diretor: "Bong Joon-ho",
    ano_lancamento: NumberInt(2019),
    classificacao_indicativa: "16+",
    elenco: ["Song Kang-ho", "Lee Sun-kyun", "Cho Yeo-jeong"],
    premiacoes: ["Oscar de Melhor Filme", "Oscar de Melhor Direção", "Palma de Ouro"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000006",
    titulo: "Mad Max: Estrada da Fúria",
    tipo: "filme",
    sinopse: "Em um deserto pós-apocalíptico, Max ajuda Imperatriz Furiosa em uma fuga em alta velocidade.",
    generos: ["Ação", "Ficção Científica"],
    genero_slugs: ["acao", "ficcao-cientifica"],
    estudio_id: "33333333-3333-4333-8333-000000000001",
    idiomas_disponiveis: { audio: ["PT-BR", "EN"], legendas: ["PT-BR", "EN"] },
    duracao_minutos: NumberInt(120),
    diretor: "George Miller",
    ano_lancamento: NumberInt(2015),
    classificacao_indicativa: "16+",
    elenco: ["Tom Hardy", "Charlize Theron", "Nicholas Hoult"],
    premiacoes: ["Oscar de Melhor Edição de Som", "Oscar de Melhor Figurino"]
  },

  // -------------------- SÉRIES --------------------
  {
    _id: "22222222-2222-4222-8222-000000000007",
    titulo: "Stranger Things",
    tipo: "serie",
    sinopse: "O desaparecimento de um garoto revela experimentos secretos e forças sobrenaturais em Hawkins.",
    generos: ["Suspense", "Ficção Científica"],
    genero_slugs: ["suspense", "ficcao-cientifica"],
    estudio_id: "33333333-3333-4333-8333-000000000002",
    idiomas_disponiveis: { audio: ["PT-BR", "EN", "ES"], legendas: ["PT-BR", "EN", "ES"] },
    // Atributos específicos de SÉRIE (com temporadas e episódios EMBUTIDOS)
    criador: "Irmãos Duffer",
    em_andamento: false,
    total_temporadas: NumberInt(2),
    temporadas: [
      {
        numero: NumberInt(1),
        ano: NumberInt(2016),
        episodios: [
          { numero: NumberInt(1), titulo: "O Desaparecimento de Will Byers", duracao_minutos: NumberInt(49) },
          { numero: NumberInt(2), titulo: "A Estranha na Rua Maple", duracao_minutos: NumberInt(55) },
          { numero: NumberInt(3), titulo: "Caramba", duracao_minutos: NumberInt(52) }
        ]
      },
      {
        numero: NumberInt(2),
        ano: NumberInt(2017),
        episodios: [
          { numero: NumberInt(1), titulo: "MADMAX", duracao_minutos: NumberInt(48) },
          { numero: NumberInt(2), titulo: "Gostosuras ou Travessuras, Aberração", duracao_minutos: NumberInt(56) }
        ]
      }
    ]
  },
  {
    _id: "22222222-2222-4222-8222-000000000008",
    titulo: "Dark",
    tipo: "serie",
    sinopse: "Quatro famílias em uma cidade alemã descobrem uma conspiração de viagens no tempo que atravessa gerações.",
    generos: ["Suspense", "Ficção Científica"],
    genero_slugs: ["suspense", "ficcao-cientifica"],
    estudio_id: "33333333-3333-4333-8333-000000000002",
    idiomas_disponiveis: { audio: ["DE", "PT-BR", "EN"], legendas: ["PT-BR", "EN", "DE"] },
    criador: "Baran bo Odar e Jantje Friese",
    em_andamento: false,
    total_temporadas: NumberInt(3),
    temporadas: [
      {
        numero: NumberInt(1),
        ano: NumberInt(2017),
        episodios: [
          { numero: NumberInt(1), titulo: "Segredos", duracao_minutos: NumberInt(51) },
          { numero: NumberInt(2), titulo: "Mentiras", duracao_minutos: NumberInt(44) }
        ]
      },
      {
        numero: NumberInt(2),
        ano: NumberInt(2019),
        episodios: [
          { numero: NumberInt(1), titulo: "Princípios e Fins", duracao_minutos: NumberInt(53) },
          { numero: NumberInt(2), titulo: "Matéria Escura", duracao_minutos: NumberInt(54) }
        ]
      },
      {
        numero: NumberInt(3),
        ano: NumberInt(2020),
        episodios: [
          { numero: NumberInt(1), titulo: "Déjà-vu", duracao_minutos: NumberInt(62) },
          { numero: NumberInt(2), titulo: "O Paraíso", duracao_minutos: NumberInt(73) }
        ]
      }
    ]
  },
  {
    _id: "22222222-2222-4222-8222-000000000009",
    titulo: "Breaking Bad",
    tipo: "serie",
    sinopse: "Um professor de química diagnosticado com câncer se une a um ex-aluno para produzir metanfetamina.",
    generos: ["Drama", "Crime"],
    genero_slugs: ["drama", "crime"],
    estudio_id: "33333333-3333-4333-8333-000000000003",
    idiomas_disponiveis: { audio: ["EN", "PT-BR", "ES"], legendas: ["PT-BR", "EN", "ES"] },
    criador: "Vince Gilligan",
    em_andamento: false,
    total_temporadas: NumberInt(2),
    temporadas: [
      {
        numero: NumberInt(1),
        ano: NumberInt(2008),
        episodios: [
          { numero: NumberInt(1), titulo: "Piloto", duracao_minutos: NumberInt(58) },
          { numero: NumberInt(2), titulo: "O Gato Está no Saco", duracao_minutos: NumberInt(48) }
        ]
      },
      {
        numero: NumberInt(2),
        ano: NumberInt(2009),
        episodios: [
          { numero: NumberInt(1), titulo: "Sete Trinta e Sete", duracao_minutos: NumberInt(47) },
          { numero: NumberInt(2), titulo: "Grelhado", duracao_minutos: NumberInt(48) }
        ]
      }
    ]
  },
  {
    _id: "22222222-2222-4222-8222-000000000010",
    titulo: "Severance",
    tipo: "serie",
    sinopse: "Funcionários de uma corporação passam por um procedimento cirúrgico que separa memórias pessoais e profissionais.",
    generos: ["Suspense", "Ficção Científica"],
    genero_slugs: ["suspense", "ficcao-cientifica"],
    estudio_id: "33333333-3333-4333-8333-000000000002",
    idiomas_disponiveis: { audio: ["EN", "PT-BR"], legendas: ["PT-BR", "EN"] },
    criador: "Dan Erickson",
    em_andamento: true,
    total_temporadas: NumberInt(2),
    temporadas: [
      {
        numero: NumberInt(1),
        ano: NumberInt(2022),
        episodios: [
          { numero: NumberInt(1), titulo: "Boas Notícias Sobre o Inferno", duracao_minutos: NumberInt(57) },
          { numero: NumberInt(2), titulo: "Meio Ciclo", duracao_minutos: NumberInt(55) }
        ]
      },
      {
        numero: NumberInt(2),
        ano: NumberInt(2025),
        episodios: [
          { numero: NumberInt(1), titulo: "Olá, Sra. Cobel", duracao_minutos: NumberInt(52) }
        ]
      }
    ]
  },
  {
    _id: "22222222-2222-4222-8222-000000000011",
    titulo: "The Last of Us",
    tipo: "serie",
    sinopse: "Em um mundo devastado por uma pandemia fúngica, Joel escolta Ellie pelos Estados Unidos.",
    generos: ["Drama", "Ação"],
    genero_slugs: ["drama", "acao"],
    estudio_id: "33333333-3333-4333-8333-000000000003",
    idiomas_disponiveis: { audio: ["EN", "PT-BR"], legendas: ["PT-BR", "EN", "ES"] },
    criador: "Craig Mazin e Neil Druckmann",
    em_andamento: true,
    total_temporadas: NumberInt(2),
    temporadas: [
      {
        numero: NumberInt(1),
        ano: NumberInt(2023),
        episodios: [
          { numero: NumberInt(1), titulo: "Quando Estiver Perdido na Escuridão", duracao_minutos: NumberInt(81) },
          { numero: NumberInt(2), titulo: "Infectados", duracao_minutos: NumberInt(53) }
        ]
      },
      {
        numero: NumberInt(2),
        ano: NumberInt(2025),
        episodios: [
          { numero: NumberInt(1), titulo: "Dias Futuros", duracao_minutos: NumberInt(59) }
        ]
      }
    ]
  },

  // -------------------- DOCUMENTÁRIOS --------------------
  {
    _id: "22222222-2222-4222-8222-000000000012",
    titulo: "Nosso Planeta",
    tipo: "documentario",
    sinopse: "Explora a beleza natural da Terra e examina como as mudanças climáticas impactam todas as criaturas vivas.",
    generos: ["Documentário", "Natureza"],
    genero_slugs: ["documentario", "natureza"],
    estudio_id: "33333333-3333-4333-8333-000000000004",
    idiomas_disponiveis: { audio: ["EN", "PT-BR"], legendas: ["PT-BR", "EN", "ES"] },
    // Atributos específicos de DOCUMENTÁRIO
    tema: "Biodiversidade e mudanças climáticas",
    ano_producao: NumberInt(2019),
    narrador: "David Attenborough",
    formato: "minisserie",
    locais_filmagem: ["Antártida", "Amazônia", "Serengeti", "Ártico"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000013",
    titulo: "O Dilema das Redes",
    tipo: "documentario",
    sinopse: "Especialistas em tecnologia alertam sobre os mecanismos de manipulação e impacto social das redes digitais.",
    generos: ["Documentário", "Tecnologia"],
    genero_slugs: ["documentario", "tecnologia"],
    estudio_id: "33333333-3333-4333-8333-000000000002",
    idiomas_disponiveis: { audio: ["EN", "PT-BR"], legendas: ["PT-BR", "EN"] },
    tema: "Impacto algorítmico das redes sociais",
    ano_producao: NumberInt(2020),
    narrador: null,
    formato: "longa",
    especialistas_entrevistados: ["Tristan Harris", "Shoshana Zuboff", "Jaron Lanier"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000014",
    titulo: "Cosmos: Mundos Possíveis",
    tipo: "documentario",
    sinopse: "Uma jornada científica pelas descobertas passadas e futuros possíveis da exploração espacial.",
    generos: ["Documentário", "Ciência"],
    genero_slugs: ["documentario", "ciencia"],
    estudio_id: "33333333-3333-4333-8333-000000000004",
    idiomas_disponiveis: { audio: ["EN", "PT-BR"], legendas: ["PT-BR", "EN"] },
    tema: "Astrofísica e história da ciência",
    ano_producao: NumberInt(2020),
    narrador: "Neil deGrasse Tyson",
    formato: "minisserie",
    instituicoes_consultadas: ["NASA", "Caltech"]
  },
  {
    _id: "22222222-2222-4222-8222-000000000015",
    titulo: "Free Solo",
    tipo: "documentario",
    sinopse: "Acompanha Alex Honnold em sua tentativa histórica de escalar o El Capitan sem cordas ou equipamentos de segurança.",
    generos: ["Documentário", "Esporte"],
    genero_slugs: ["documentario", "esporte"],
    estudio_id: "33333333-3333-4333-8333-000000000004",
    idiomas_disponiveis: { audio: ["EN", "PT-BR"], legendas: ["PT-BR", "EN"] },
    tema: "Escalada em rocha sem cordas no El Capitan",
    ano_producao: NumberInt(2018),
    narrador: null,
    formato: "longa",
    locais_filmagem: ["Parque Nacional de Yosemite"]
  }
]);

// 3. Avaliações (REFERENCIADAS por conteudo_id e usuario_id)
dbRef.avaliacoes.insertMany([
  { conteudo_id: "22222222-2222-4222-8222-000000000001", usuario_id: "11111111-1111-4111-8111-000000000001", nota: NumberInt(5), comentario: "Trilha sonora e roteiro impecáveis.", criado_em: new Date("2026-11-10T20:15:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000001", usuario_id: "11111111-1111-4111-8111-000000000002", nota: NumberInt(5), comentario: "Melhor ficção científica da década.", criado_em: new Date("2026-11-11T22:00:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000001", usuario_id: "11111111-1111-4111-8111-000000000003", nota: NumberInt(4), comentario: "Visual incrível, final emocionante.", criado_em: new Date("2026-11-12T19:40:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000002", usuario_id: "11111111-1111-4111-8111-000000000001", nota: NumberInt(5), comentario: "Conceito genial de camadas de sonhos.", criado_em: new Date("2026-11-13T21:10:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000003", usuario_id: "11111111-1111-4111-8111-000000000002", nota: NumberInt(5), comentario: "Fotografia absurda.", criado_em: new Date("2026-11-14T23:05:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000007", usuario_id: "11111111-1111-4111-8111-000000000005", nota: NumberInt(4), comentario: "Clima dos anos 80 excelente.", criado_em: new Date("2026-11-15T18:30:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000008", usuario_id: "11111111-1111-4111-8111-000000000002", nota: NumberInt(5), comentario: "Roteiro fechado nos mínimos detalhes.", criado_em: new Date("2026-11-16T21:45:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000010", usuario_id: "11111111-1111-4111-8111-000000000009", nota: NumberInt(5), comentario: "Suspense corporativo muito original.", criado_em: new Date("2026-11-17T20:00:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000012", usuario_id: "11111111-1111-4111-8111-000000000004", nota: NumberInt(5), comentario: "Imagens impressionantes da natureza.", criado_em: new Date("2026-11-18T16:20:00Z") },
  { conteudo_id: "22222222-2222-4222-8222-000000000013", usuario_id: "11111111-1111-4111-8111-000000000006", nota: NumberInt(4), comentario: "Muito relevante para entender algoritmos.", criado_em: new Date("2026-11-19T19:10:00Z") }
]);

print("Estúdios inseridos:   ", dbRef.estudios.countDocuments());
print("Conteúdos inseridos:  ", dbRef.conteudos.countDocuments());
print("  - Filmes:           ", dbRef.conteudos.countDocuments({ tipo: "filme" }));
print("  - Séries:           ", dbRef.conteudos.countDocuments({ tipo: "serie" }));
print("  - Documentários:    ", dbRef.conteudos.countDocuments({ tipo: "documentario" }));
print("Avaliações inseridas: ", dbRef.avaliacoes.countDocuments());
print("=== [MongoDB] Carga concluída com sucesso! ===");
