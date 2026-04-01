-- Cuentas que tienen auxiliar y no se peuden afectar por el mayor
-- 
-- Creado    : 04/01/2005 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_sac27;

CREATE PROCEDURE "informix".sp_sac27(a_periodo char(7))
returning char(20),
		  char(50),
		  date,
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(5);

define _no_poliza		char(20);
define _no_documento	char(20);

define _saldo			dec(16,2);
define _por_vencer      dec(16,2);
define _exigible        dec(16,2);
define _corriente       dec(16,2);
define _dias_30         dec(16,2);
define _dias_60         dec(16,2);
define _dias_90         dec(16,2);

define _cod_coasegur	char(3);
define _cia_lider		char(3);
define _nombre_coasegur	char(50);
define _cod_auxiliar	char(5);

define _cod_contratante	char(10);
define _nombre_cliente	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;

set isolation to dirty read;

select par_ase_lider
  into _cia_lider
  from parparam
 where cod_compania = "001";

foreach
 select c.saldo,
		c.no_documento,
		c.no_poliza,
		c.por_vencer,
		c.exigible,
		c.corriente,
		c.dias_30,
		c.dias_60,
		c.dias_90,
		p.cod_contratante,
		p.vigencia_inic,
		p.vigencia_final
   into _saldo,
        _no_documento,
		_no_poliza,
		_por_vencer,
		_exigible,
		_corriente,
		_dias_30,
		_dias_60,
		_dias_90,
		_cod_contratante,
		_vigencia_inic,
		_vigencia_final
   from cobmoros c, emipomae p
  where c.periodo      = a_periodo
	and c.no_poliza    = p.no_poliza
	and p.cod_tipoprod = "001"
	and c.saldo        <> 0.00

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	foreach
	 select cod_coasegur
	   into _cod_coasegur
	   from emicoama
	  where no_poliza    = _no_poliza
	    and cod_coasegur <> _cia_lider

		select nombre,
		       cod_auxiliar
		  into _nombre_coasegur,
		       _cod_auxiliar
		  from emicoase
		 where cod_coasegur = _cod_coasegur;

		return _no_documento,
			   _nombre_cliente,
			   _vigencia_inic,
			   _vigencia_final,
		       _saldo,
			   _por_vencer,
			   _exigible,
			   _corriente,
			   _dias_30,
			   _dias_60,
			   _dias_90,
			   _cod_coasegur,
			   _nombre_coasegur,
			   _cod_auxiliar
			   with resume;
					
	end foreach	

end foreach

end procedure