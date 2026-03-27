-- Atividade 2

--1. Listagem dos hóspedes contendo nome e data de nascimento, ordenada em ordem crescente por nome e decrescente por data de nascimento.
SELECT nome, dt_nasc FROM HOSPEDE ORDER BY nome, dt_nasc DESC;

--2. Listagem contendo os nomes das categorias, ordenados alfabeticamente. A coluna de nomes deve ter a palavra ‘Categoria’ como título.
SELECT nome AS Categoria FROM CATEGORIA ORDER BY nome;

--3. Listagem contendo os valores de diárias e os números dos apartamentos, ordenada em ordem decrescente de valor.
SELECT valor_dia, num FROM APTO a
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
ORDER BY valor_dia DESC;

--4. Categorias que possuem apenas um apartamento.
SELECT * FROM CATEGORIA c
JOIN (SELECT c.cod_cat, COUNT(num) AS qtd_apto FROM
CATEGORIA c JOIN APTO a
ON a.cod_cat = c.cod_cat
GROUP BY c.cod_cat) AS t
ON c.cod_cat = t.cod_cat
WHERE qtd_apto = 1;

--5. Listagem dos nomes dos hóspedes brasileiros com mês e ano de nascimento, por ordem decrescente de idade e por ordem crescente de nome do hóspede.
SELECT nome FROM HOSPEDE WHERE NACIONALIDADE ILIKE 'BRASILEIR_' ORDER BY DT_NASC, NOME;

--6. Listagem com 3 colunas, nome do hóspede, número do apartamento e quantidade (número de vezes que aquele hóspede se hospedou naquele apartamento), em ordem decrescente de quantidade.
SELECT H.NOME, HO.NUM_QUARTO, COUNT(*) AS QTD_VEZES
FROM HOSPEDAGEM HO
JOIN HOSPEDE H
ON HO.COD_HOSP = H.COD_HOSP
GROUP BY HO.NUM_QUARTO, H.NOME
ORDER BY QTD_VEZES DESC;

--7. Categoria cujo nome tenha comprimento superior a 15 caracteres.
SELECT * FROM CATEGORIA WHERE LENGTH(NOME) > 15;

--8. Número dos apartamentos ocupados no ano de 2017 com o respectivo nome da sua categoria.
SELECT NUM, NOME FROM HOSPEDAGEM H JOIN APTO A
ON H.NUM_QUARTO = A.NUM
NATURAL JOIN CATEGORIA C
WHERE EXTRACT(YEAR FROM DT_ENT) = 2017;

-- 10. Adicione o atributo salário em Funcionario, deixando o valor padrão como 1000.
ALTER TABLE FUNCIONARIO ADD SALARIO FLOAT DEFAULT 1000;

--11. Mostre o nome e o salário de cada funcionário. Extraordinariamente, cada funcionário receberá um acréscimo neste salário de 10 reais para cada hospedagem realizada.
SELECT NOME, SALARIO + COUNT(cod_hospedagem) * 10 AS SALARIO
FROM FUNCIONARIO f 
LEFT JOIN HOSPEDAGEM h
ON f.cod_func = h.cod_func
GROUP BY(f.cod_func);

--12. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar também o número do apartamento, ordenada pelo nome da categoria e pelo número do apartamento.
SELECT NOME, NUM FROM CATEGORIA c 
LEFT JOIN APTO a ON c.cod_cat = a.cod_cat
ORDER BY NOME, NUM;

--13. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar 
-- também o número do apartamento, ordenada pelo nome da categoria e pelo número do
-- apartamento. Para aquelas que não possuem apartamentos associados, escrever "não possui apartamento".
SELECT NOME, COALESCE(CAST(NUM AS VARCHAR), 'NÃO POSSUI APTO') 
FROM CATEGORIA c 
LEFT JOIN APTO a ON c.cod_cat = a.cod_cat
ORDER BY NOME, NUM;

--14. O nome dos funcionário que atenderam o João (hospedando ou reservando) ou que hospedaram ou reservaram apartamentos da categoria luxo.
SELECT NOME FROM FUNCIONARIO WHERE COD_FUNC IN 
(SELECT COD_FUNC FROM HOSPEDAGEM NATURAL JOIN HOSPEDE WHERE NOME ILIKE 'JOÃO')
OR COD_FUNC IN(SELECT COD_FUNC FROM RESERVA NATURAL JOIN HOSPEDE WHERE NOME ILIKE 'JOÃO')
OR COD_FUNC IN (SELECT COD_FUNC FROM HOSPEDAGEM HO JOIN APTO A
ON HO.NUM_QUARTO = A.NUM JOIN CATEGORIA C
ON A.COD_CAT = C.COD_CAT WHERE NOME ILIKE 'LUXO')
OR COD_FUNC IN (SELECT COD_FUNC FROM RESERVA R JOIN APTO A
ON R.NUM_QUARTO = A.NUM JOIN CATEGORIA C
ON A.COD_CAT = C.COD_CAT WHERE NOME ILIKE 'LUXO');

--15. O código das hospedagens realizadas pelo hóspede mais velho que se hospedou no apartamento mais caro.
SELECT COD_HOSPEDAGEM FROM HOSPEDAGEM WHERE COD_HOSP =
(SELECT COD_HOSP FROM HOSPEDAGEM HO
NATURAL JOIN HOSPEDE H
JOIN APTO A ON A.NUM = HO.NUM_QUARTO
JOIN CATEGORIA C ON C.COD_CAT = A.COD_CAT
ORDER BY VALOR_DIA DESC, DT_NASC LIMIT 1); 

--16. Sem usar subquery, o nome dos hóspedes que nasceram na mesma data do hóspede de código 2.
SELECT H1.NOME FROM HOSPEDE H1 
JOIN HOSPEDE H2 
ON H1.DT_NASC = H2.DT_NASC
WHERE H2.COD_HOSP = 2
AND H1.COD_HOSP <> 2;

--17. O nome do hóspede mais velho que se hospedou na categoria mais cara mo ano de 2026.
CREATE VIEW HOSPEDAGENS2026 AS
SELECT HO.NOME, DT_NASC, VALOR_DIA
FROM HOSPEDE HO JOIN HOSPEDAGEM H 
ON HO.COD_HOSP = H.COD_HOSP
JOIN APTO A ON H.NUM_QUARTO = A.NUM 
JOIN CATEGORIA C ON C.COD_CAT = A.COD_CAT 
WHERE EXTRACT(YEAR FROM DT_ENT) = 2026
ORDER BY VALOR_DIA DESC, DT_NASC;

SELECT DISTINCT NOME FROM HOSPEDAGENS2026 WHERE 
DT_NASC = (SELECT MIN(DT_NASC) FROM HOSPEDAGENS2026 WHERE
VALOR_DIA = (SELECT MAX(VALOR_DIA) FROM HOSPEDAGENS2026));

--18. O nome das categorias que foram reservadas pela Maria ou que foram ocupadas pelo João quando ele foi atendido pelo Joaquim.
SELECT NOME FROM CATEGORIA WHERE COD_CAT IN
(SELECT COD_CAT FROM APTO WHERE NUM IN
(SELECT NUM_QUARTO FROM RESERVA WHERE COD_HOSP IN
(SELECT COD_HOSP FROM HOSPEDE WHERE NOME = 'Claudenes'))) 
OR COD_CAT IN 
(SELECT COD_CAT FROM APTO WHERE NUM IN
(SELECT NUM_QUARTO FROM HOSPEDAGEM WHERE COD_HOSP IN
(SELECT COD_HOSP FROM HOSPEDE WHERE NOME = 'João') AND COD_FUNC IN
(SELECT COD_FUNC FROM FUNCIONARIO WHERE NOME = 'Claudia')));

--19. O nome e a data de nascimento dos funcionários, além do valor de diária mais cara reservado por cada um deles.
SELECT F.NOME, DT_NASC, COALESCE(CAST(MAX(VALOR_DIA) AS VARCHAR), 'NÃO TEM RESERVA') AS DIARIA_MAIS_CARA 
FROM FUNCIONARIO F
LEFT JOIN RESERVA R ON F.COD_FUNC = R.COD_FUNC
LEFT JOIN APTO A ON A.NUM = R.NUM_QUARTO 
LEFT JOIN CATEGORIA C ON C.COD_CAT = A.COD_CAT
GROUP BY F.COD_FUNC;

--20. A quantidade de apartamentos ocupados por cada um dos hóspedes (mostrar o nome).
SELECT NOME, COUNT(NUM_QUARTO) AS QTD_APTO_OCUPADOS FROM HOSPEDE H
LEFT JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP
GROUP BY H.COD_HOSP;

--21. A relação com o nome dos hóspedes, a data de entrada, a data de saída e o valor total pago em diárias (não é necessário considerar a hora de entrada e saída, apenas as datas).
SELECT NOME, DT_ENT, DT_SAIDA, VALOR_TOTAL FROM HOSPEDAGEM NATURAL JOIN HOSPEDE;

--22. O nome dos hóspedes que já se hospedaram em todos os apartamentos do hotel.
SELECT COD_HOSP, NOME FROM HOSPEDE
NATURAL JOIN HOSPEDAGEM GROUP BY COD_HOSP, NOME 
HAVING COUNT(DISTINCT NUM_QUARTO) = (SELECT COUNT(*) FROM APTO);