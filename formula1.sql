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
('Germany'),      
('Austria'),       
('Italy'),         
('United Kingdom'),
('France'),      
('Netherlands'), 
('Mexico'), 
('Monaco'),
('Spain'),        
('Australia');     

INSERT INTO equipes (nome, pais_id) VALUES
('Mercedes', 1),       
('Red Bull Racing', 2),
('Ferrari', 3),           
('McLaren', 4),  
('Alpine', 5);           

INSERT INTO piloto (nome, pais_id, equipe_id) VALUES
('Lewis Hamilton', 4, 1),  
('George Russell', 4, 1),  
('Max Verstappen', 6, 2),  
('Sergio Pérez', 7, 2),    
('Charles Leclerc', 8, 3), 
('Carlos Sainz', 9, 3),    
('Lando Norris', 4, 4),    
('Daniel Ricciardo', 10, 4),     
('Fernando Alonso', 9, 5),          
('Esteban Ocon', 5, 5);           


INSERT INTO pistas (nome, pais_id) VALUES
('Silverstone Circuit', 4),                  
('Circuit Zandvoort', 6),                    
('Autódromo Hermanos Rodríguez', 7),         
('Circuit de Monaco', 8),                    
('Circuit de Barcelona-Catalunya', 9);       


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
);


CREATE INDEX ON pontos_por_corrida USING HASH (piloto_id);


--view no estilo olimpiadas