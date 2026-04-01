--**************************************************************
-- R E P O R T E para consurso a Milan 2008 Corredores
--**************************************************************

-- Creado    : 11/06/2008 - Autor: Armando Moreno M.
-- Modificado: 20/06/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che86b;

CREATE PROCEDURE sp_che86b(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
RETURNING char(5),char(50),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),INT,INT,DEC(16,2),smallint,smallint,char(20);

define _cod_agente   		 char(5);
define _nombre_agente   	 char(50);
define _sini_inc			 dec(16,2);
define _siniestralidad  	 dec(16,2);
define _pri_sus_pag     	 dec(16,2);
define _crecimiento     	 dec(16,2);
define _crecimiento2    	 dec(16,2);
define _pri_sus_pag_ap  	 dec(16,2);
define _vigente_aa           int;
define _vigente_ap           int;
define _aplica               smallint;
define _cre_prima_aplica     smallint;
define _min_prima_pag_aplica smallint;
define _cre_pol_vig_aplica   smallint;
define _sini_aplica          smallint;
define _tiene				 smallint;
define _no_documento         char(20);
define _cnt					 smallint;

--SET DEBUG FILE TO "sp_che86a.trc";   
--TRACE ON;

let _crecimiento  		  = 0;
let _crecimiento2 		  = 0;
let _aplica       	      = 0;
let _sini_aplica          = 0;
let _cre_prima_aplica     = 0;
let _min_prima_pag_aplica = 0;
let _cre_pol_vig_aplica   = 0;
let _tiene                = 0;

create temp table tmp_con(
cod_agente      char(5),
no_documento	char(20),
pri_sus_pag		dec(16,2) 	default 0,
pri_sus_pag_ap  dec(16,2) 	default 0,
sini_inc        dec(16,2) 	default 0,
pol_vig_aa      dec(16,2) 	default 0,
pol_vig_ap      dec(16,2) 	default 0
) with no log;

foreach

	 select cod_agente,
	        pri_sus_pag,
			sini_inc,
			vigente,
			no_documento
	   into _cod_agente,
	        _pri_sus_pag,
			_sini_inc,
			_vigente_aa,
			_no_documento
	   from concurso

--	  where cod_agente = "00083"

	insert into tmp_con(cod_agente, no_documento, pri_sus_pag, sini_inc, pol_vig_aa)
	values (_cod_agente, _no_documento, _pri_sus_pag, _sini_inc, _vigente_aa );

end foreach

foreach

	 select pri_sus_pag,
	        vigente,
			no_documento,
			cod_agente
	   into _pri_sus_pag_ap,
	        _vigente_ap,
			_no_documento,
			_cod_agente
	   from concurso2

--	  where cod_agente = "00083"

	 if _pri_sus_pag_ap is null then
		let _pri_sus_pag_ap = 0;
	 end if

	 select count(*)
	   into _cnt
	   from tmp_con
	  where no_documento = _no_documento
	    and cod_agente   = _cod_agente;

	 if _cnt = 0 then
		insert into tmp_con(cod_agente,no_documento, pri_sus_pag_ap, pol_vig_ap)
		values (_cod_agente, _no_documento, _pri_sus_pag_ap, _vigente_ap );

	 else
		update tmp_con
		   set pri_sus_pag_ap = _pri_sus_pag_ap,
		       pol_vig_ap     =	_vigente_ap
		 where no_documento   = _no_documento
		   and cod_agente     = _cod_agente;
	 end if

end foreach

foreach

	 select cod_agente,
	        pri_sus_pag,
			sini_inc,
			pol_vig_aa,
			no_documento,
			pri_sus_pag_ap,
			pol_vig_ap
	   into _cod_agente,
	        _pri_sus_pag,
			_sini_inc,
			_vigente_aa,
			_no_documento,
			_pri_sus_pag_ap,
			_vigente_ap
	   from tmp_con

--	  where cod_agente = "00083"

	SELECT nombre
	  INTO _nombre_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;



	RETURN _cod_agente,
		   _nombre_agente,
		   _pri_sus_pag,
		   _sini_inc,
		   0,
		   _pri_sus_pag_ap,
		   0,
		   _vigente_aa,
		   _vigente_ap,
		   0,
		   0,
		   0,
		   _no_documento
		   WITH RESUME;

end foreach

drop table tmp_con;

END PROCEDURE;

						 
