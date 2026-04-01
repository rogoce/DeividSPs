-- Formulario de Endoso de aceptacion recargo / exclusiones dependientes

-- Creado    : 13/01/2011 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro202eee;

CREATE PROCEDURE "informix".sp_pro202eee(a_no_eval char(10))
returning varchar(100),varchar(100),varchar(100),varchar(100),smallint,smallint,smallint,varchar(50),dec(16,2),varchar(20),varchar(20),smallint,varchar(255);


define _nombre			 varchar(100);

define _cod_asegurado 	 char(10);
define _exclusion1		 char(5);
define _exclusion2		 char(5);
define _exclusion3		 char(5);
define _tiempo1			 smallint;
define _tiempo2			 smallint;
define _tiempo3			 smallint;
define _n_excl1			 varchar(100);
define _n_excl2   		 varchar(100);
define _n_excl3			 varchar(100);
define _cod_parent       char(5);
define _n_paren          varchar(50);
define _porc    		 dec(16,2);
define _excl_peso_char    varchar(20);
define _excl_fumador_char varchar(20);
define _excl_peso		 dec(16,2);
define _excl_fumador	 dec(16,2);
define _procesado		 smallint;
define _obs_especiales   varchar(255);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202e.trc";
--trace on;

BEGIN


let _porc         = 0;
let _excl_peso	  = 0;
let _excl_fumador = 0;
let _procesado    = 0;

let _n_excl1 = null;
let	_n_excl2 = null;
let	_n_excl3 = null;
let _n_paren = "";
let _excl_peso_char    = "";
let	_excl_fumador_char = "";
let _obs_especiales    = "";

foreach
	select cod_asegurado,
		   exclusion1,
		   exclusion2,
		   exclusion3,
		   tiempo1,
		   tiempo2,
		   tiempo3,
		   cod_parentesco,
		   excl_peso + excl_fumador,
		   excl_peso,
		   excl_fumador,
		   procesado,
		   obs_especiales
	  into _cod_asegurado,
		   _exclusion1,
		   _exclusion2,
		   _exclusion3,
		   _tiempo1,
		   _tiempo2,
		   _tiempo3,
		   _cod_parent,
		   _porc,
		   _excl_peso,
		   _excl_fumador,
		   _procesado,
		   _obs_especiales
	  from emievade
	 where no_evaluacion = a_no_eval
	  -- and procesado     = 0

	select nombre
	  into _n_paren
	  from emiparen
	 where cod_parentesco = _cod_parent;

 let _excl_peso_char = "";

 if _excl_peso > 0 then
   let _excl_peso_char = _excl_peso || "% Condicion.";
 end if

 if _excl_fumador > 0 then
   let _excl_fumador_char = _excl_fumador || "% Fumador.";
 end if

 if _exclusion1 is not null or _exclusion1 <> "" then

	select nombre
	  into _n_excl1
	  from emiproce
	 where cod_procedimiento = _exclusion1;
 else
	let _n_excl1 = null;
 end if

 if _exclusion2 is not null or _exclusion2 <> "" then

	select nombre
	  into _n_excl2
	  from emiproce
	 where cod_procedimiento = _exclusion2;
 else
	 let _n_excl2 = null;
 end if

 if _exclusion3 is not null or _exclusion3 <> "" then

	select nombre
	  into _n_excl3
	  from emiproce
	 where cod_procedimiento = _exclusion3;
 else
	 let _n_excl3 = null;
 end if


select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_asegurado;


return _nombre,
	   _n_excl1,
	   _n_excl2,
	   _n_excl3,
	   _tiempo1,
	   _tiempo2,
	   _tiempo3,
	   _n_paren,
	   _porc,
	   _excl_peso_char,
	   _excl_fumador_char,
	   _procesado,
	   _obs_especiales
	    with resume;

end foreach
END
END PROCEDURE
