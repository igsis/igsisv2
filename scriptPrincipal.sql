use igsisv2;

DROP FUNCTION IF EXISTS fn_altera_nome_usuario;
DELIMITER //
CREATE FUNCTION fn_altera_nome_usuario(nomeUsuario varchar(60)) RETURNS varchar(7)
  BEGIN    
    
    IF(length(nomeUsuario) >= 8) THEN  
      SET @usuario = substring(nomeUsuario, 1, 7);
      RETURN @usuario;
    END IF;

   RETURN nomeUsuario;   
    
  END//
DELIMITER ;

DROP PROCEDURE IF EXISTS cr_altera_data_cadastro;
DELIMITER //
CREATE PROCEDURE cr_altera_data_cadastro()
  BEGIN
    UPDATE 
     igsis.usuarios 
    SET 
     dataCadastro = current_date
    WHERE usuarios.idUsuario > 0;
  END //
DELIMITER ;   

DROP PROCEDURE IF EXISTS pr_altera_tamanho_campo;
DELIMITER //
CREATE PROCEDURE pr_altera_tamanho_campo(nomeTabela varchar(50), nomeCampo varchar(25), tamanhoCampo int)
  BEGIN    

   SET @myQuery = concat('ALTER TABLE ', nomeTabela,' CHANGE ', nomeCampo, ' ', nomeCampo, ' varchar(',tamanhoCampo,')');

    PREPARE stmt FROM @myQuery;
	EXECUTE stmt;
      
  END//
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_remove_registro;
DELIMITER //
CREATE PROCEDURE pr_remove_registro(nomeTabela varchar(50), idUsuario int(10)) 
  BEGIN    

   SET @exec = concat('DELETE FROM ', nomeTabela, ' WHERE idUsuario = ', idUsuario);    

   PREPARE myQuery FROM @exec;
   EXECUTE myQuery; 

  END//
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_atualiza_telefone;
DELIMITER //
CREATE PROCEDURE pr_atualiza_telefone()
  BEGIN    
    UPDATE 
      usuarios
    SET 
      telefone = REPLACE(substring(telefone, 1,15), '/', '')
    WHERE length(usuarios.telefone) > 16
    AND idUsuario > 0;
  END//
DELIMITER ;

DROP PROCEDURE IF exists remove_dados_inconsistentes_telefone;
DELIMITER //
CREATE PROCEDURE remove_dados_inconsistentes_telefone()
  BEGIN
     UPDATE
      usuarios
     SET telefone = null
     WHERE telefone like 'não%'
     AND idUsuario >= 1;
  END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE pr_altera_dataCadastro()
  BEGIN
    UPDATE 
      usuarios 
    SET 
      dataCadastro = current_date
    WHERE usuarios.idUsuario > 0;
  END //
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_altera_locais_endereco;
DELIMITER //
CREATE PROCEDURE pr_altera_locais_endereco()
  BEGIN
    UPDATE 
      locais AS l 
    INNER JOIN 
      enderecos AS e 
    ON e.instituicao = l.idInstituicao

    SET 
      l.idEndereco = e.idEndereco  
    WHERE l.idLocal > 0
    AND  e.idEndereco > 0;  
    
    ALTER TABLE enderecos DROP COLUMN  instituicao;
 
  END //
DELIMITER ;


DROP PROCEDURE IF EXISTS pr_insert_instituicoes;
DELIMITER //
CREATE PROCEDURE pr_insert_instituicoes()
  BEGIN
    INSERT INTO 
      instituicoes(
        idInstituicao, 
        nome, sigla
     )  
  
    SELECT 
      idInstituicao, 
      instituicao, 
      sigla
    FROM 
      igsis.ig_instituicao;
  END //
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_insert_usuarios;
DELIMITER //
CREATE PROCEDURE pr_insert_usuarios()
  BEGIN  
    INSERT INTO 
      usuarios(
        idUsuario, 
        nomeCompleto, 
		usuario, 
		senha, 
		email, 
		telefone, 
		publicado, 
		idInstituicao
	  )
  
  SELECT 
    idUsuario, 
    nomeCompleto, 
    fn_altera_nome_usuario(nomeUsuario),    
    senha, 
    email, 
    telefone, 
    publicado, 
    idInstituicao
  FROM 
    igsis.ig_usuario;

   SET @idUsuario = (SELECT idUsuario FROM usuarios where usuario like '%não%');       
   CALL pr_remove_registro('usuarios', @idUsuario);   
   CALL pr_atualiza_telefone;         
   CALL remove_dados_inconsistentes_telefone();
   CALL pr_altera_dataCadastro(); 
  END //
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_insert_usuarioContratos;
DELIMITER //
CREATE PROCEDURE pr_insert_usuarioContratos()
  BEGIN    
    INSERT INTO 
      usuarioContratos(
        idUsuario    
    )

    SELECT 
      idUsuario   
    FROM 
      usuarios;
  
    SET SQL_SAFE_UPDATES=0; /*Desabilita o parametro em edit\preferences\sqlEditor\safeUpdates*/
    UPDATE usuarioContratos AS uc
      INNER JOIN  igsis.ig_usuario AS userIg 
      ON  userIg.idUsuario = uc.idUsuario
    
      SET 
        uc.nivelAcesso = userIg.contratos
      WHERE userIg.contratos IS NOT NULL;      

  END//
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_insert_enderecos;
DELIMITER //
CREATE PROCEDURE pr_insert_enderecos()
  BEGIN      
    
   ALTER TABLE 
     enderecos 
   ADD COLUMN 
     instituicao INT;

    INSERT INTO 
      enderecos(
        instituicao, 
        logradouro, 
        numero, 
        complemento, 
        bairro, 
        cep, 
        cidade, 
        uf
     )
     VALUES
       (3,"Viaduto do Chá","15",null,"Centro","01020-900","São Paulo","SP"),
	   (4,"Av. São João","473",null,"Centro","01034-001","São Paulo","SP"),
	   (5,"rua Vergueiro","1000",null,"Liberdade","01504-000","São Paulo","SP"),
	   (6,"av. Dep. Emílio Carlos","3641",null,"Vila Nova Cachoeirinha","02720-200","São Paulo","SP"),
	   (7,"av. São João","473",null,"Centro","01034-001","São Paulo","SP"),
	   (8,"av. São João","473",null,"Centro","01034-001","São Paulo","SP"),
	   (9,"Largo do Rosário","20",null,"Penha","03634-020","São Paulo","SP"),
	   (10,"rua Inácio Monteiro","6900",null,"Conj. Hab. Sitio Conceicao","08490-000","São Paulo","SP"),
	   (12,"Praça Ramos de Azevedo","s/n",null,"República","01037-010","São Paulo","SP"),
	   (13,"rua da Consolação","94",null,"Consolação","01302-000","São Paulo","SP"),
	   (20,"Av. Olavo Fontoura","1209",null,"Santana","04290-100","São Paulo","SP"),
	   (24,"rua Constança","72",null,"Lapa","05033-020","São Paulo","SP"),
	   (25,"rua Arsênio Tavolieri","45",null,"Jardim Oriental","04321-030","São Paulo","SP"),
	   (28,"av. Nadir Dias de Figueiredo","s/n","Portaria 1"," Vila Guilherme","02110-000","São Paulo","SP"),
	   (29,"av. Renata","63",null,"Chácara Belenzinho","03377-000","São Paulo","SP"),
	   (32,"Bom Retiro","s/n",null,"Bom Retiro","01123-001","São Paulo","SP");
  END //
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_insert_locais;
DELIMITER //
CREATE PROCEDURE pr_insert_locais()
  BEGIN  
   INSERT INTO 
     locais(
     idLocal, 
     nome, 
     idInstituicao,
     idEndereco
    )    
    SELECT 
      l.idLocal, 
      l.sala,
      l.idInstituicao, 
      NULL 
    FROM 
      igsis.ig_local AS l 
    INNER JOIN instituicoes AS i 
    ON i.idInstituicao = l.idInstituicao;
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_usuarioLocais;
DELIMITER //
CREATE PROCEDURE pr_insert_usuarioLocais()
  BEGIN  
   INSERT INTO 
     usuarioLocais(
     idUsuario,    
     idLocal
   )    
   SELECT 
     userIg.idUsuario, userIg.local 
   FROM 
     igsis.ig_usuario AS userIg 
  
   INNER JOIN usuarios AS user 
   ON user.idUsuario = userIg.idUsuario
  
   INNER JOIN locais AS l 
   ON l.idLocal = userIg.local  
   
   WHERE userIg.local NOT LIKE '%,%';    
   
  END //
DELIMITER ; 

CREATE TABLE IF NOT EXISTS tmp_usuarios (
  id int(11) AUTO_INCREMENT, 
  idUsuario int,  
  novo_local int,
  PRIMARY KEY(id)  
);

DROP FUNCTION IF EXISTS fn_cria_temp_table_usuarioLocal; 
DELIMITER //
CREATE FUNCTION fn_cria_temp_table_usuarioLocal(idUser int) RETURNS int
  BEGIN    
    DECLARE contador int DEFAULT 1;

    SET @numVoltas = ( 
      SELECT             
        LENGTH(local) - LENGTH(TRIM(REPLACE(local, ',',''))) AS TotalVirgulas   
       FROM 
         igsis.ig_usuario 
       WHERE local LIKE '%,%'
       AND idUsuario = idUser
    ) + 1;        
  
    WHILE contador <= @numVoltas DO       
      INSERT INTO tmp_usuarios(idUsuario, novo_local) VALUES(
       (SELECT idUsuario FROM igsis.ig_usuario WHERE idusuario = idUser), 
       (SELECT substring_index(substring_index(local,',',contador),',',-1) FROM igsis.ig_usuario WHERE idUsuario = idUser));   
       
      SET contador = contador + 1;    
    END WHILE;

    RETURN idUser;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS pr_cria_temp_usuarioLocais;
DELIMITER //
CREATE PROCEDURE pr_cria_temp_usuarioLocais()
  BEGIN  
    SELECT 
      fn_cria_temp_table_usuarioLocal(idUsuario)
    FROM 
      igsis.ig_usuario
     WHERE LOCAL LIKE '%,%';
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_usuarioLocais_complemento
DELIMITER //
CREATE PROCEDURE pr_insert_usuarioLocais_complemento()
  BEGIN  
    INSERT INTO 
      usuarioLocais(
      idUsuario,    
      idLocal
    )       
    SELECT 
      tempUser.idUsuario, 
      tempUser.novo_local 
    FROM 
      tmp_usuarios AS tempUser 
  
    INNER JOIN usuarios AS user 
    ON user.idUsuario = tempUser.idUsuario
  
    INNER JOIN locais AS l 
    ON l.idLocal = tempUser.novo_local;
    
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_delete_tmp_usuarios
DELIMITER //
CREATE PROCEDURE pr_delete_tmp_usuarios()
  BEGIN      
    DROP TABLE IF EXISTS tmp_usuarios;
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_cargos;
DELIMITER //
CREATE PROCEDURE pr_insert_cargos()
  BEGIN  
   INSERT INTO 
     igsisv2.cargos(
       idCargo,
       descricao,
       coordenador,
       justificativa
   )    
   SELECT 
     id_cargo,
     cargo,
     coordenador,
     justificativa
   FROM 
     igsis.sis_formacao_cargo;    
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_coordenadorias;
DELIMITER //
CREATE PROCEDURE pr_insert_coordenadorias()
  BEGIN  
   INSERT INTO 
     igsisv2.coordenadorias(
       idCoordenadoria,
       descricao       
   )    
   SELECT 
     idCoordenadoria,
     coordenadoria     
   FROM 
     igsis.sis_formacao_coordenadoria;    
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_linguagens;
DELIMITER //
CREATE PROCEDURE pr_insert_linguagens()
  BEGIN  
   INSERT INTO 
     igsisv2.linguagens(
       idLinguagem,
       descricao       
   )    
   SELECT 
     id_linguagem,
     linguagem     
   FROM 
     igsis.sis_formacao_linguagem;    
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_projetos;
DELIMITER //
CREATE PROCEDURE pr_insert_projetos()
  BEGIN  
   INSERT INTO 
     igsisv2.projetos(
       idProjeto,
       descricao       
   )    
   SELECT 
     id_projeto,
     projeto     
   FROM 
     igsis.sis_formacao_projeto;    
  END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS pr_insert_subPrefeitura;
DELIMITER //
CREATE PROCEDURE pr_insert_subPrefeitura()
  BEGIN  
   INSERT INTO 
     igsisv2.subPrefeituras(
       idSubPrefeitura,
       nome       
   )    
   SELECT 
     id_subPrefeitura,
     subPrefeitura     
   FROM 
     igsis.sis_formacao_subPrefeitura;    
  END //
DELIMITER ; 



/*Modulo ADM*/
CALL pr_insert_instituicoes();
CALL pr_insert_usuarios();
CALL pr_altera_tamanho_campo('usuarios', 'usuario', 7);
CALL pr_insert_usuarioContratos;
CALL pr_insert_enderecos;
CALL pr_insert_locais;
CALL pr_altera_locais_endereco;
CALL pr_insert_usuarioLocais;
CALL pr_cria_temp_usuarioLocais();
CALL pr_insert_usuarioLocais_complemento;
CALL pr_delete_tmp_usuarios;

/*Modulo Formacao*/
CALL pr_insert_cargos;
CALL pr_insert_coordenadorias;
CALL pr_insert_linguagens;
CALL pr_insert_projetos;
CALL pr_insert_subPrefeitura;






