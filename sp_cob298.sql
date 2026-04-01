-- procedimiento para armar el correo del reporte de inconsistencia de polizas que reciben pago y estan canceladas por falta de pago
-- creado    : 08/11/2011 - autor: Roman Gordon

drop procedure sp_cob298;
create procedure "informix".sp_cob298(a_secuencia integer)
returning	char(20),  --_no_documento
			char(50),  --_nombre_cli
			char(50),  --_motivo_canc
			dec(16,2), --_monto_recibido
			dec(16,2), --_prima_devengada
			dec(16,2), --_credito_favor
			char(50),  --_nom_div_cob
			char(50),  --v_cobrador
			char(100), --v_agente
			char(50),  --_forma_pag 
			char(10),
			date,
			char(10);

define _error_desc			char(100);
define _nom_div_cob			char(50);
define _motivo_canc			char(50);
define _nombre_cli			char(50);
define _forma_pag			char(50);
define _cobrador			char(50);
define _agente				char(50);
define _email				char(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _no_recibo			char(10);
define _periodo				char(7);
define _cod_agente  		char(5);
define _cod_no_renov		char(3);
define _cod_cobrador		char(3);
define _cod_formapag		char(3);
define _cod_div_cob			char(1);
define _prima_devengada		dec(16,2);
define _credito_favor		dec(16,2);
define _monto_recibido		dec(16,2);
define _leasing				smallint;
define _renglon				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_remesa		date;

--set debug file to "sp_cob298.trc";
--trace on;
set isolation to dirty read;

foreach
	select no_documento,
	       asegurado,
		   saldo,
		   saldo61,
		   prima_mensual,
		   no_remesa,
		   renglon
	  into _no_documento,
	  	   _nombre_cli,
		   _prima_devengada,
		   _credito_favor,
		   _monto_recibido,
		   _no_remesa,
		   _renglon
	  from parmailcomp
	 where mail_secuencia = a_secuencia

	let _no_poliza = sp_sis21(_no_documento);

	call sp_cob116(_no_poliza) 
	returning	_cod_agente,  
				_agente,      
				_cod_cobrador,
				_cobrador,
				_leasing,
				_cod_div_cob,
				_nom_div_cob;    

	select e_mail
	  into _email
	  from agtagent
	 where cod_agente = _cod_agente;

	select date_posteo
	  into _fecha_remesa
	  from cobremae
	 where no_remesa = _no_remesa;

	select no_recibo
	  into _no_recibo
	  from cobredet
	 where no_remesa	= _no_remesa
	   and renglon		= _renglon;

	select cod_no_renov,
		   cod_formapag
	  into _cod_no_renov,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _motivo_canc
	  from eminoren
	 where cod_no_renov = _cod_no_renov;

	select nombre
	  into _forma_pag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	return _no_documento,	   		-- 1
		   _nombre_cli,		   		-- 2
		   _motivo_canc,	   		-- 3
		   _monto_recibido,	   		-- 4
		   _prima_devengada,   		-- 5
		   _credito_favor,	   		-- 6
		   _nom_div_cob,	   		-- 7
		   _cobrador,		   		-- 8
		   _agente,			   		-- 9
		   _forma_pag,		   		-- 10
		   _no_remesa,		   		-- 11
		   _fecha_remesa,	   		-- 12
		   _no_recibo with resume;	-- 13
end foreach
end procedure;