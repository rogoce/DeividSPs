-- Procedure que Carga los Reclamos Pendientes para BO

-- Creado:	06/12/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_sis514;

create procedure sp_sis514()
returning	integer			as code_error,
			varchar(100)	as nom_cliente;


define _nom_cliente			varchar(100);
define _direccion_1		varchar(50);
define _direccion_2		varchar(50);
define _cod_estafeta		varchar(50);
define _nom_subramo			varchar(50);
define _nom_ramo			varchar(50);
define _grupo				varchar(50);	
define _cedula				char(50);
define _no_documento		char(20);
define _cod_asegurado		char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _porc_comis_subramo	dec(5,2);
define _porc_comision_esp	dec(5,2);
define _porc_comis_ramo		dec(5,2);
define _porc_partic_agt		dec(5,2);
define _porc_comis_tab		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _prima_neta			dec(16,2);	
define _saldo				dec(16,2);	
define _no_pagos			smallint;
define _anio				integer;
define _flag				smallint;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _fecha_suscripcion	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

		   

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return 	_error,_error_desc;
end exception


foreach
	select can.cod_contratante,
		   con.direccion_1,
		   con.cod_estafeta
	  into _cod_asegurado,
		   _direccion_1,
		   _cod_estafeta
	  from avisocanc can
	 inner join emipomae emi on emi.no_poliza = can.no_poliza
	 inner join cliclien cli on cli.cod_cliente = can.cod_contratante
	 inner join cliclien con on con.cod_cliente = emi.cod_contratante
	 where can.no_aviso = '02351'
	   and emi.cod_contratante = '699702'
	   and (cli.direccion_1 is null or trim(cli.direccion_1) = '')

	update cliclien 
	   set direccion_1 = _direccion_1,
	       cod_estafeta = _cod_estafeta	   
	 where cod_cliente = _cod_asegurado;
end foreach
end
end procedure;