-- Estudios Adicionales

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro202a;

CREATE PROCEDURE "informix".sp_pro202a(a_no_eval char(10))
returning varchar(100),char(10),varchar(255),char(8),varchar(30),varchar(50),varchar(100),varchar(100),varchar(100),smallint,smallint,smallint,varchar(20),varchar(20),dec(16,2),varchar(255);


define _nombre	 	 	varchar(100);
define _user_eval	 	char(8);
define _requisitos_obs	varchar(255);
define _n_evaluadora    varchar(30);
define _req_adic 	    smallint;
define _cod_asegurado   char(10);
define _n_agente        varchar(50);
define _cod_agente      char(5);

define _exclusion1		 char(5);
define _exclusion2		 char(5);
define _exclusion3		 char(5);
define _tiempo1			 smallint;
define _tiempo2			 smallint;
define _tiempo3			 smallint;
define _n_excl1			 varchar(100);
define _n_excl2   		 varchar(100);
define _n_excl3			 varchar(100);
define _excl_peso		 dec(16,2);
define _excl_fumador	 dec(16,2);
define _excl_peso_char    varchar(20);
define _excl_fumador_char varchar(20);
define _porc             dec(16,2);
define _obs_especiales   varchar(255);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202a.trc";
--trace on;

let _req_adic = 0;
let _n_agente = "";
let _porc         = 0;
let _excl_peso	  = 0;
let _excl_fumador = 0;

let _n_excl1 = "";
let	_n_excl2 = "";
let	_n_excl3 = "";
let _excl_peso_char    = "";
let	_excl_fumador_char = "";
let _obs_especiales    = "";


BEGIN

select nombre,
	   requisitos_obs,
	   usuario_eval,
	   requisitos_adic,
	   cod_asegurado,
	   cod_agente,
	   excl_peso + excl_fumador,
	   exclusion1,
	   exclusion2,
	   exclusion3,
	   tiempo1,
	   tiempo2,
	   tiempo3,
	   excl_peso,
	   excl_fumador,
	   obs_especiales
  into _nombre,
	   _requisitos_obs,
	   _user_eval,
	   _req_adic,
	   _cod_asegurado,
	   _cod_agente,
	   _porc,
	   _exclusion1,
	   _exclusion2,
	   _exclusion3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3,
	   _excl_peso,
	   _excl_fumador,
	   _obs_especiales
  from emievalu
 where no_evaluacion = a_no_eval;

if _user_eval is null then
	let _user_eval = "";
end if

 if _excl_peso > 0 then
   --let _excl_peso_char = _excl_peso || "% Condicion.";
   let _excl_peso_char = _excl_peso || "% " || _obs_especiales;
 end if

 if _excl_fumador > 0 then
   let _excl_fumador_char = _excl_fumador || "% Fumador.";
 end if

 if _exclusion1 is not null or _exclusion1 <> "" then

	select nombre
	  into _n_excl1
	  from emiproce
	 where cod_procedimiento = _exclusion1;

 end if

 if _exclusion2 is not null or _exclusion2 <> "" then

	select nombre
	  into _n_excl2
	  from emiproce
	 where cod_procedimiento = _exclusion2;

 end if

 if _exclusion3 is not null or _exclusion3 <> "" then

	select nombre
	  into _n_excl3
	  from emiproce
	 where cod_procedimiento = _exclusion3;

 end if

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;

if _req_adic = 0 then
	 let _requisitos_obs = "";
end if

select nombre
  into _n_agente
  from agtagent
 where cod_agente = _cod_agente;

if _n_agente is null then
	let _n_agente = "";
end if

select descripcion
  into _n_evaluadora
  from insuser
 where usuario = _user_eval;


return _nombre,
	   a_no_eval,
	   _requisitos_obs,
	   _user_eval,
	   _n_evaluadora,
	   _n_agente,
   	   _n_excl1,
	   _n_excl2,
	   _n_excl3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3,
   	   _excl_peso_char,
	   _excl_fumador_char,
	   _porc,
	   _obs_especiales;

END
END PROCEDURE
