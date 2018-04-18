drop database if exists igsisv2;
create database igsisv2;
use igsisv2;
-- MySQL Workbench Synchronization
-- Generated: 2018-04-18 17:47
-- Model: New Model
-- Version: 1.0
-- Project: Name of the project
-- Author: x028641

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `igsisv2` DEFAULT CHARACTER SET utf8 ;

CREATE TABLE IF NOT EXISTS `igsisv2`.`grupoUsuarios` (
  `idGrupoUsuario` INT(11) NOT NULL AUTO_INCREMENT,
  `codigoGrupo` VARCHAR(3) NOT NULL,
  `descricao` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`idGrupoUsuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`modulos` (
  `idModulo` INT(11) NOT NULL AUTO_INCREMENT,
  `sigla` VARCHAR(5) NOT NULL,
  `descricao` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`idModulo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`modulosGrupos` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `idGrupoUsuario` INT(11) NOT NULL,
  `idModulo` INT(11) NOT NULL,
  INDEX `fk_grupoUsuarios_has_modulos_modulos1_idx` (`idModulo` ASC),
  INDEX `fk_grupoUsuarios_has_modulos_grupoUsuarios_idx` (`idGrupoUsuario` ASC),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_grupoUsuarios_has_modulos_grupoUsuarios`
    FOREIGN KEY (`idGrupoUsuario`)
    REFERENCES `igsisv2`.`grupoUsuarios` (`idGrupoUsuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_grupoUsuarios_has_modulos_modulos1`
    FOREIGN KEY (`idModulo`)
    REFERENCES `igsisv2`.`modulos` (`idModulo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`usuarios` (
  `idusuario` INT(11) NOT NULL AUTO_INCREMENT,
  `nomeCompleto` VARCHAR(120) NOT NULL,
  `usuario` VARCHAR(60) NULL DEFAULT NULL,
  `senha` VARCHAR(40) NOT NULL,
  `email` VARCHAR(60) NOT NULL,
  `telefone` VARCHAR(45) NULL DEFAULT NULL,
  `dataCadastro` DATE NULL DEFAULT NULL,
  `publicado` TINYINT(4) NOT NULL,
  `idInstituicao` INT(11) NOT NULL,
  `idGrupoUsuario` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`idusuario`, `idInstituicao`),
  INDEX `fk_usuarios_grupoUsuarios1_idx` (`idGrupoUsuario` ASC),
  INDEX `fk_usuarios_instituicoes1_idx` (`idInstituicao` ASC),
  CONSTRAINT `fk_usuarios_grupoUsuarios1`
    FOREIGN KEY (`idGrupoUsuario`)
    REFERENCES `igsisv2`.`grupoUsuarios` (`idGrupoUsuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usuarios_instituicoes1`
    FOREIGN KEY (`idInstituicao`)
    REFERENCES `igsisv2`.`instituicoes` (`idInstituicao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`usuariosContratos` (
  `idUsuario` INT(11) NOT NULL,
  `nivelAcesso` INT(11) NULL DEFAULT NULL,
  INDEX `fk_usuariosContrato_usuarios1_idx` (`idUsuario` ASC),
  PRIMARY KEY (`idUsuario`),
  CONSTRAINT `fk_usuariosContrato_usuarios1`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `igsisv2`.`usuarios` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`usuariosPagamentos` (
  `idUsuario` INT(11) NOT NULL,
  `nivelAcesso` INT(11) NOT NULL,
  INDEX `fk_usuariosContrato_usuarios1_idx` (`idUsuario` ASC),
  PRIMARY KEY (`idUsuario`),
  CONSTRAINT `fk_usuariosContrato_usuarios10`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `igsisv2`.`usuarios` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`instituicoes` (
  `idInstituicao` INT(11) NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(60) NOT NULL,
  `sigla` VARCHAR(12) NOT NULL,
  PRIMARY KEY (`idInstituicao`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`locais` (
  `idLocal` INT(11) NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `rider` VARCHAR(250) NULL DEFAULT NULL,
  `idInstituicao` INT(11) NOT NULL,
  `idEndereco` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`idLocal`, `idInstituicao`),
  INDEX `fk_locais_instituicoes1_idx` (`idInstituicao` ASC),
  INDEX `fk_locais_endereco1_idx` (`idEndereco` ASC),
  CONSTRAINT `fk_locais_instituicoes1`
    FOREIGN KEY (`idInstituicao`)
    REFERENCES `igsisv2`.`instituicoes` (`idInstituicao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_locais_endereco1`
    FOREIGN KEY (`idEndereco`)
    REFERENCES `igsisv2`.`enderecos` (`idEndereco`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`usuariosLocais` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `idUsuario` INT(11) NOT NULL,
  `idLocal` INT(11) NOT NULL,
  PRIMARY KEY (`id`, `idUsuario`, `idLocal`),
  INDEX `fk_usuarios_has_locais_locais1_idx` (`idLocal` ASC),
  INDEX `fk_usuarios_has_locais_usuarios1_idx` (`idUsuario` ASC),
  CONSTRAINT `fk_usuarios_has_locais_usuarios1`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `igsisv2`.`usuarios` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usuarios_has_locais_locais1`
    FOREIGN KEY (`idLocal`)
    REFERENCES `igsisv2`.`locais` (`idLocal`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`espacos` (
  `idEspaco` INT(11) NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(60) NOT NULL,
  `publicado` TINYINT(4) NOT NULL,
  `idLocal` INT(11) NOT NULL,
  PRIMARY KEY (`idEspaco`),
  INDEX `fk_espacos_locais1_idx` (`idLocal` ASC),
  CONSTRAINT `fk_espacos_locais1`
    FOREIGN KEY (`idLocal`)
    REFERENCES `igsisv2`.`locais` (`idLocal`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`ceps` (
  `idCep` INT(11) NOT NULL AUTO_INCREMENT,
  `logradouro` VARCHAR(70) NOT NULL,
  `bairro` VARCHAR(72) NOT NULL,
  `cidade` VARCHAR(50) NOT NULL,
  `uf` VARCHAR(2) NOT NULL,
  PRIMARY KEY (`idCep`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`enderecos` (
  `idEndereco` INT(11) NOT NULL AUTO_INCREMENT,
  `logradouro` VARCHAR(100) NOT NULL,
  `numero` VARCHAR(10) NOT NULL,
  `complemento` VARCHAR(50) NULL DEFAULT NULL,
  `bairro` VARCHAR(45) NOT NULL,
  `cep` VARCHAR(9) NOT NULL,
  `cidade` VARCHAR(50) NOT NULL,
  `uf` VARCHAR(250) NULL DEFAULT NULL,
  PRIMARY KEY (`idEndereco`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `igsisv2`.`weblogs` (
  `idWeblog` INT(11) NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(240) NOT NULL,
  `mensagem` LONGTEXT NOT NULL,
  `data` DATETIME NOT NULL,
  `publicado` TINYTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`idWeblog`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
