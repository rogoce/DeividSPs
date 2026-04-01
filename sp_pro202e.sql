-- Formulario de Endoso de aceptacion recargo / exclusiones

-- Creado    : 13/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro202e;

CREATE PROCEDURE sp_pro202e(a_no_eval char(10))
returning varchar(100),date,smallint,char(20),varchar(50),varchar(50),varchar(30),dec(16,2),varchar(100),varchar(100),varchar(100),smallint,smallint,smallint,varchar(255),varchar(20),varchar(20),
          varchar(100),varchar(100),smallint,smallint;


define _nombre			 varchar(100);
define _fecha_nacimiento date;
define _identidad		 smallint;
define _identidad_otro	 char(20);
define _user_scan		 char(8);
define _suma_asegurada   dec(16,2);

define _cod_agente		 char(5);
define _cod_producto	 char(5);
define _usuario_eval	 char(8);
define _porc             dec(16,2);
define _n_agente         varchar(50);
define _n_prod			 varchar(50);
define _n_usuario_eval   varchar(30);
define _exclusion1		 char(5);
define _exclusion2		 char(5);
define _exclusion3		 char(5);
define _exclusion4		 char(5);
define _exclusion5		 char(5);
define _tiempo1			 smallint;
define _tiempo2			 smallint;
define _tiempo3,_tiempo4,_tiempo5			 smallint;
define _n_excl1			 varchar(100);
define _n_excl2   		 varchar(100);
define _n_excl3			 varchar(100);
define _n_excl4   		 varchar(100);
define _n_excl5			 varchar(100);
define _obs_esp          varchar(255);
define _cod_asegurado    char(10);
define _excl_peso		 dec(16,2);
define _excl_fumador	 dec(16,2);
define _excl_peso_char    varchar(20);
define _excl_fumador_char varchar(20);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202e.trc";
--trace on;

BEGIN

let _porc         = 0;
let _excl_peso	  = 0;
let _excl_fumador = 0;

let _n_excl1 = "";
let	_n_excl2 = "";
let	_n_excl3 = "";
let	_n_excl4 = "";
let	_n_excl5 = "";
let	_obs_esp = "";
let _excl_peso_char    = "";
let	_excl_fumador_char = "";

select nombre,
       fecha_nacimiento,
	   identidad,
	   identidad_otro,
	   cod_agente,
	   plan,
	   usuario_eval,
	   excl_peso + excl_fumador,
	   exclusion1,
	   exclusion2,
	   exclusion3,
	   tiempo1,
	   tiempo2,
	   tiempo3,
	   obs_especiales,
	   cod_asegurado,
	   excl_peso,
	   excl_fumador,
	   exclusion4,
	   exclusion5,
	   tiempo4,
	   tiempo5
  into _nombre,
	   _fecha_nacimiento,
	   _identidad,
	   _identidad_otro,
	   _cod_agente,
	   _cod_producto,
	   _usuario_eval,
	   _porc,
	   _exclusion1,
	   _exclusion2,
	   _exclusion3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3,
	   _obs_esp,
	   _cod_asegurado,
	   _excl_peso,
	   _excl_fumador,
	   _exclusion4,
	   _exclusion5,
	   _tiempo4,
	   _tiempo5
  from emievalu
 where no_evaluacion = a_no_eval;

 if _excl_peso > 0 then
   let _excl_peso_char = _excl_peso || "% Condicion.";
 end if

 if _excl_fumador > 0 then
   let _excl_fumador_char = _excl_fumador || "% Fumador.";
 end if

 if _obs_esp is null then
	let _obs_esp = "";
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
 if _exclusion4 is not null or _exclusion4 <> "" then

	select nombre
	  into _n_excl4
	  from emiproce
	 where cod_procedimiento = _exclusion4;

 end if
 if _exclusion5 is not null or _exclusion5 <> "" then

	select nombre
	  into _n_excl5
	  from emiproce
	 where cod_procedimiento = _exclusion5;

 end if

select nombre
  into _n_agente
  from agtagent
 where cod_agente = _cod_agente;

select nombre
  into _n_prod
  from prdprod
 where cod_producto = _cod_producto;

select descripcion
  into _n_usuario_eval
  from insuser
 where usuario = _usuario_eval;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;

return _nombre,
	   _fecha_nacimiento,
	   _identidad,
	   _identidad_otro,
	   _n_agente,
	   _n_prod,
	   _n_usuario_eval,
	   _porc,
	   _n_excl1,
	   _n_excl2,
	   _n_excl3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3,
	   _obs_esp,
	   _excl_peso_char,
	   _excl_fumador_char,
	   _n_excl4,
	   _n_excl5,
	   _tiempo4,
	   _tiempo5;

END
END PROCEDURE
