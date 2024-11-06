CREATE TABLE pais (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL
);

CREATE TABLE equipes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	pais_id INT REFERENCES pais(id) NOT NULL
);

CREATE TABLE piloto (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	pais_id INT REFERENCES pais(id) NOT NULL,
	equipe_id INT REFERENCES equipes(id)
);

CREATE TABLE pistas (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	pais_id INT REFERENCES pais(id) NOT NULL
);

CREATE TABLE grande_premio (
	id SERIAL PRIMARY KEY,
	pista_id INT REFERENCES pistas(id) NOT NULL,
	ano INT NOT NULL,
	campeao INT REFERENCES piloto(id) NOT NULL,
	vice INT REFERENCES piloto(id) NOT NULL,
	terceiro INT REFERENCES piloto(id) NOT NULL
);


INSERT INTO pais (nome) VALUES
('Germany'),       -- id 1
('Austria'),       -- id 2
('Italy'),         -- id 3
('United Kingdom'),
('France'),      
('Netherlands'), 
('Mexico'), 
('Monaco'),
('Spain'),        
('Australia');     

-- Insert teams into 'equipes'
INSERT INTO equipes (nome, pais_id) VALUES
('Mercedes', 1),        -- id 1
('Red Bull Racing', 2), -- id 2
('Ferrari', 3),           -- id 3
('McLaren', 4),  -- id 4
('Alpine', 5);           -- id 5

-- Insert drivers into 'piloto'
INSERT INTO piloto (nome, pais_id, equipe_id) VALUES
('Lewis Hamilton', 4, 1),  -- id 1
('George Russell', 4, 1),  -- id 2
('Max Verstappen', 6, 2),     -- id 3
('Sergio Pérez', 7, 2),            -- id 4
('Charles Leclerc', 8, 3),         -- id 5
('Carlos Sainz', 9, 3),             -- id 6
('Lando Norris', 4, 4),    -- id 7
('Daniel Ricciardo', 10, 4),     -- id 8
('Fernando Alonso', 9, 5),          -- id 9
('Esteban Ocon', 5, 5);            -- id 10

-- Insert tracks into 'pistas'
INSERT INTO pistas (nome, pais_id) VALUES
('Silverstone Circuit', 4),                  -- id 1
('Circuit Zandvoort', 6),                    -- id 2
('Autódromo Hermanos Rodríguez', 7),         -- id 3
('Circuit de Monaco', 8),                    -- id 4
('Circuit de Barcelona-Catalunya', 9);       -- id 5

-- Insert Grand Prix into 'grande_premio'
INSERT INTO grande_premio (pista_id, ano, campeao, vice, terceiro) VALUES
(1, 2022, 1, 2, 3),  -- Silverstone Circuit 2022
(2, 2022, 3, 4, 5),  -- Circuit Zandvoort 2022
(3, 2022, 3, 1, 6),  -- Autódromo Hermanos Rodríguez 2022
(4, 2022, 5, 6, 7),  -- Circuit de Monaco 2022
(5, 2022, 6, 5, 9);  -- Circuit de Barcelona-Catalunya 2022

CREATE TABLE pontos_por_corrida (
    id SERIAL PRIMARY KEY,
    grande_premio_id INT REFERENCES grande_premio(id),
    piloto_id INT REFERENCES piloto(id),
    pontos INT NOT NULL
);

SELECT * FROM pontos_por_corrida;

-- Inserir pontos para campeão, vice e terceiro lugar
INSERT INTO pontos_por_corrida (grande_premio_id, piloto_id, pontos)
SELECT id, campeao, 3 FROM grande_premio
UNION ALL
SELECT id, vice, 2 FROM grande_premio
UNION ALL
SELECT id, terceiro, 1 FROM grande_premio;

CREATE VIEW campeao_temporada AS
SELECT ano, piloto_id, nome, total_pontos FROM (
    SELECT
        gp.ano,
        p.id AS piloto_id,
        p.nome,
        SUM(ppc.pontos) AS total_pontos,
        RANK() OVER (PARTITION BY gp.ano ORDER BY SUM(ppc.pontos) DESC) AS posicao
    FROM grande_premio gp
    JOIN pontos_por_corrida ppc ON gp.id = ppc.grande_premio_id
    JOIN piloto p ON ppc.piloto_id = p.id
    GROUP BY gp.ano, p.id, p.nome
) sub
WHERE posicao = 1;

SELECT * FROM pontos_por_corrida
	WHERE piloto_id = 2;

-- Motivo: Índices GiST são úteis para consultas por intervalo e podem ser usados para otimizar consultas que envolvem somas ou médias de pontos.
CREATE INDEX ON pontos_por_corrida USING HASH (piloto_id);