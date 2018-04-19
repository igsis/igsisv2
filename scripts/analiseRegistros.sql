USE igsisv2;

DROP TABLE IF exists logCopia;

CREATE TABLE logCopia(
  id int auto_increment,
  old_igsis int,
  new_igsis int,
  nomeTabela varchar(50),
  primary key(id)
);

INSERT INTO logCopia(old_igsis, new_igsis, nomeTabela)
  VALUES( 
    (SELECT COUNT(idInstituicao) FROM igsis.ig_instituicao),
    (SELECT COUNT(idInstituicao) FROM instituicoes),
	'Instituicoes');

INSERT INTO logCopia(old_igsis, new_igsis, nomeTabela)
  VALUES( 
    (SELECT COUNT(idInstituicao) FROM igsis.ig_usuario),
    (SELECT COUNT(idInstituicao) FROM usuarios),
	'Usuarios');

INSERT INTO logCopia(old_igsis, new_igsis, nomeTabela)
  VALUES( 
    (SELECT COUNT(idUsuario) FROM igsis.ig_usuario WHERE contratos IS NOT NULL),
    (SELECT COUNT(idUsuario) FROM usuariosContratos WHERE nivelAcesso IS NOT NULL),
	'UsuariosContratos');

INSERT INTO logCopia(old_igsis, new_igsis, nomeTabela)
  VALUES(0,         
    (SELECT COUNT(idEndereco) FROM enderecos),
	'Enderecos');

INSERT INTO logCopia(old_igsis, new_igsis, nomeTabela)
  VALUES( 
    (SELECT COUNT(idLocal) FROM igsis.ig_local),
    (SELECT COUNT(idLocal) FROM locais),
	'Locais');
    
INSERT INTO logCopia(old_igsis, new_igsis, nomeTabela)
  VALUES( 
    (SELECT 
        COUNT(igUser.idUsuario) 
      FROM 
        igsis.ig_usuario as igUser
      INNER JOIN 
        usuariosLocais AS ul
      ON ul.idUsuario = igUser.idUsuario),
     (SELECT 
        COUNT(ul.idUsuario) 
      FROM 
        igsis.ig_usuario as igUser
      INNER JOIN 
        usuariosLocais AS ul
      ON ul.idUsuario = igUser.idUsuario),     
	'UsuariosLocais');    

SELECT * FROM logCopia;


    
         





   
  