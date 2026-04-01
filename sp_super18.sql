-- Procedimiento para generar informacion de devoluciones de prima para auditoria interna(Sr. Henry Machado).

-- Creado    : 12/06/2017 - Autor: Armando Moreno M.

drop procedure sp_super18;
create procedure "informix".sp_super18(a_periodo char(7))
RETURNING char(10),char(20),varchar(75),date,dec(16,2),dec(16,2),char(50),char(50),date,date,char(5),char(50),date,char(50),char(12);

define _cod_formapag	  char(3);
define _no_poliza         char(10);
define _no_requis		  char(10);
define _n_formapag        char(50);
define _cod_no_renov	  char(3);
define _monto,_saldo      dec(16,2);
define _prima_bruta       dec(16,2);
define _n_ramo            char(50);
define _n_no_renov        char(50);
define _estatus_poliza    char(12);
define _a_nombre_de       varchar(75);
define _fecha_captura     date;
define _periodo           char(7);
define _fecha_impresion   date;
define _no_documento      char(20);
define _cod_ramo          char(3);
define _vig_ini, _vig_fin date;
define _fecha_suscripcion date;
define _cod_agente        char(5);
define _n_agente          char(50);
define _estatus           smallint;

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

foreach

	select no_requis,
	       monto,
		   a_nombre_de,
		   fecha_captura,
		   periodo,
		   fecha_impresion
	  into _no_requis,
	       _monto,
		   _a_nombre_de,
		   _fecha_captura,
		   _periodo,
		   _fecha_impresion
	  from chqchmae
     where origen_cheque = '6'
       and periodo >= a_periodo
       and autorizado = 1
       and pagado = 1

	foreach
	   select no_poliza
	     into _no_poliza
	     from chqchpol
	    where no_requis = _no_requis
		
		exit foreach;
	end foreach

    select cod_formapag,
	       no_documento,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   cod_no_renov,
		   fecha_suscripcion,
		   prima_bruta
	  into _cod_formapag,
		   _no_documento,
		   _cod_ramo,
		   _vig_ini,
		   _vig_fin,
		   _estatus,
		   _cod_no_renov,
		   _fecha_suscripcion,
		   _prima_bruta
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _saldo = 0;
	let _saldo = sp_cob85('001','001',_no_documento);
	
	if _estatus = 1 then
		let _estatus_poliza = 'Vigente';
	elif _estatus = 2 then
		let _estatus_poliza = 'Cancelada';
	elif _estatus = 3 then
	    let _estatus_poliza = 'Vencida';
	else	
		let _estatus_poliza = 'Anulada';
	end if	
	
	foreach
	   select cod_agente
	     into _cod_agente
	     from emipoagt
	    where no_poliza = _no_poliza
		
		exit foreach;
	end foreach
	
	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _n_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	 
	select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
	  into _n_no_renov
	  from eminoren
	 where cod_no_renov = _cod_no_renov;

	let _a_nombre_de = trim(_a_nombre_de);
	return _no_requis,_no_documento,_a_nombre_de,_fecha_suscripcion,_prima_bruta,_saldo,_n_formapag,_n_ramo,_vig_ini,_vig_fin,_cod_agente,_n_agente,
           _fecha_impresion,_n_no_renov,_estatus_poliza	with resume;
end foreach
END
end procedure