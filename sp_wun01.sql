-- Procedimiento que Carga los Saldos para Western Union
-- 
-- Creado    : 14/05/2009 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_wun01;		

create procedure "informix".sp_wun01() 
returning integer,
          char(50);

define _no_documento				varchar(20);
define _equi_no_documento			char(21);
define _no_poliza					char(10);
define _saldo						dec(16,2);

define _cod_contratante				char(10);
define _cod_pagador					char(10);
define _cod_asegurado				char(10);
define _cod_ramo					char(3);
define _cedula_contratante  		varchar(30);
define _cedula_asegurado			varchar(30);
define _cedula_pagador              varchar(30);
define _tipo_persona_pagador        char(1);
define _tipo_persona_asegurado      char(1);
define _tipo_persona_contratante    char(1);


define _nombre_contratante	varchar(100);
define _nombre_pagador		varchar(100);
define _nombre_asegurado	varchar(100);
define _nombre_ramo			char(100);
define _no_secuencia		integer;

define _vigencia_inic		date;
define _vigencia_final		date;

define _ano					char(4);
define _mes					char(2);
define _dia					char(2);

define _vig_inic			char(8);
define _vig_final			char(8);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(100);

define _contador			smallint;
define _estatus_poliza      smallint;
define _cod_tipocan         char(3);
define _corriente			dec(16,2);
define _monto_30	        dec(16,2);
define _monto_60            dec(16,2);
define _monto_90			dec(16,2);
define _monto_120			dec(16,2);
define _monto_150			dec(16,2);
define _monto_180			dec(16,2);
define _exigible			dec(16,2);
define _monto_90mas         dec(16,2);
define _pagominimo          dec(16,2);
define _pasaporte           smallint;
define _cnt_poliza          smallint;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

delete from deivid_cob:wun_saldos;
delete from deivid_cob:gr_clientes;

-- let _contador = 0;
 --SET DEBUG FILE TO "sp_wun01.trc";      
 --TRACE ON;     

let _monto_90mas = 0.00;
let _monto_180 = 0.00;
let _monto_150 = 0.00;
let _monto_120 = 0.00;
let _monto_90 = 0.00;
let _monto_60 = 0.00;
let _monto_30 = 0.00;

foreach
	select no_documento,
		   saldo,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   exigible
	  into _no_documento,
		   _saldo,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _exigible
	  from emipoliza
	 where saldo > 0

	let _no_secuencia = 0;
	let _no_poliza = sp_sis21(_no_documento);	
	let _monto_90mas = _monto_120 + _monto_150 + _monto_180;
	let _cnt_poliza = 0; 
	
	select count(*)
	 into _cnt_poliza
	 from ofac
	where no_documento = _no_documento;
	
	if _cnt_poliza is null then
		let _cnt_poliza = 0;
	end if
	
	if _cnt_poliza <> 0 then
		continue foreach;
	end if
	
	
	select cod_contratante,
	       cod_pagador,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   estatus_poliza
	  into _cod_contratante,
	       _cod_pagador,
	       _vigencia_inic,
	       _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

    if _estatus_poliza = 2 or _estatus_poliza = 4 then	--> incluir la opcion de que no pasen las polizas canceladas 10/03/2015
	    {let _cod_tipocan = "";
		foreach
			select cod_tipocan
			  into _cod_tipocan
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '002'
			   and actualizado = 1
			order by no_endoso desc 
			exit foreach;
		end foreach
        if _cod_tipocan = "001" then
		end if}
		
		continue foreach;
	end if

	let _ano = year(_vigencia_inic);
	let _mes = month(_vigencia_inic);
	let _dia = day(_vigencia_inic);

	if _mes < 10 then
		let	_mes = '0'|| _mes;
	end if

	if _dia < 10 then
		let	_dia = '0'|| _dia;
	end if

	let _vig_inic = _ano || _mes || _dia;

	let _ano = year(_vigencia_final);
	let _mes = month(_vigencia_final);
	let _dia = day(_vigencia_final);

	if _mes < 10 then
		let	_mes = '0'|| _mes;
	end if

	if _dia < 10 then
		let	_dia = '0'|| _dia;
	end if

	let _vig_final = _ano || _mes || _dia;

	foreach
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
	  	exit foreach;
	end foreach
	
	select cedula,
	       tipo_persona,
		   nombre
	  into _cedula_contratante,
		   _tipo_persona_contratante,
		   _nombre_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select cedula,
	       tipo_persona,
		   nombre
	  into _cedula_pagador,
		   _tipo_persona_pagador,
		   _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select cedula,
	       tipo_persona,
		   nombre,
		   pasaporte
	  into _cedula_asegurado,
		   _tipo_persona_asegurado,
		   _nombre_asegurado,
		   _pasaporte
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _no_secuencia = _no_secuencia + 1;
	
	if _corriente = 0 or _corriente = 0.00 then
		let _pagominimo = 0.00;
	else
		let _pagominimo = 2.00;
	end if
	
	call sp_wun04_new(_cedula_contratante,_tipo_persona_contratante,_pasaporte)returning _cedula_contratante;
	let _equi_no_documento = lpad(trim(_no_documento),20,'0');
	
	insert into deivid_cob:wun_saldos(
			no_documento,
			cod_cliente,
			nom_cliente,
			saldo,
			ramo,
			vigencia_inic,
			vigencia_final,
			cod_estado,
			no_secuencia,
			no_poliza,
			equi_no_documento)
	values(	_no_documento,
			_cod_contratante,
			_nombre_contratante,
			_saldo,
			_nombre_ramo,
			_vig_inic,
			_vig_final,
			'D',
			_no_secuencia,
			_no_poliza,
			_equi_no_documento);

	--grupo rey		
	insert into deivid_cob:gr_clientes(
			cuenta,
			cliente,
			saldocorriente,
			saldo30,
			saldo60,
			saldo90,
			saldo90mas,
			estado,
			observacion,
			pagominimo,
			fechavence,
			descsaldocorriente,
			descsaldo30,
			descsaldo60,
			descsaldo90,
			descsaldo90mas,
			opt_02,
			deuda_total,
			cedula)
	values(	trim(_no_documento),
			trim(_nombre_contratante),
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_monto_90mas,
			'A',
			' ',
			_pagominimo,
			_vigencia_final,
			'Saldo Corriente',
			'Morosidad 30 dias',
			'Morosidad 60 dias',
			'Morosidad 90 dias',
			'Morosidad a mas de 90 dias',
			' ',
			_saldo,
			trim(_cedula_contratante));		

	if _cod_pagador <> '' AND _cod_pagador IS NOT NULL then
		if _cod_contratante <> _cod_pagador then

		    let _no_secuencia = _no_secuencia + 1;

			insert into deivid_cob:wun_saldos(
					no_documento,
					cod_cliente,
					nom_cliente,
					saldo,
					ramo,
					vigencia_inic,
					vigencia_final,
					cod_estado,
					no_secuencia,
					no_poliza)
			values(	_no_documento,
					_cod_pagador,
					_nombre_pagador,
					_saldo,
					_nombre_ramo,
					_vig_inic,
					_vig_final,
					'D',
					_no_secuencia,
					_no_poliza);

			--grupo rey
			call sp_wun04_new(_cedula_pagador,_tipo_persona_pagador,_pasaporte)returning _cedula_pagador;		

			insert into deivid_cob:gr_clientes(
					cuenta,
					cliente,
					saldocorriente,
					saldo30,
					saldo60,
					saldo90,
					saldo90mas,
					estado,
					observacion,
					pagominimo,
					fechavence,
					descsaldocorriente,
					descsaldo30,
					descsaldo60,
					descsaldo90,
					descsaldo90mas,
					opt_02,
					deuda_total,
					cedula)
			values(	trim(_no_documento),
					trim(_nombre_pagador),
					_corriente,
					_monto_30,
					_monto_60,
					_monto_90,
					_monto_90mas,
					'A',
					' ',
					_pagominimo,
					_vigencia_final,
					'Saldo Corriente',
					'Morosidad 30 dias',
					'Morosidad 60 dias',
					'Morosidad 90 dias',
					'Morosidad a mas de 90 dias',
					' ',
					_saldo,
					trim(_cedula_pagador));
		end if
	end if 

	if _cod_asegurado <> '' AND _cod_asegurado IS NOT NULL then

		if _cod_contratante <> _cod_asegurado then

	 		let _no_secuencia = _no_secuencia + 1;

			insert into deivid_cob:wun_saldos(
					no_documento,
					cod_cliente,
					nom_cliente,
					saldo,
					ramo,
					vigencia_inic,
					vigencia_final,
					cod_estado,
					no_secuencia,
					no_poliza)
			values(	_no_documento,
					_cod_asegurado,
					_nombre_asegurado,
					_saldo,
					_nombre_ramo,
					_vig_inic,
					_vig_final,
					'D',
					_no_secuencia,
					_no_poliza);

			--grupo rey
			call sp_wun04_new(_cedula_asegurado,_tipo_persona_asegurado,_pasaporte)returning _cedula_asegurado;

			insert into deivid_cob:gr_clientes(
			cuenta,
			cliente,
			saldocorriente,
			saldo30,
			saldo60,
			saldo90,
			saldo90mas,
			estado,
			pagominimo,
			fechavence,
			descsaldocorriente,
			descsaldo30,
			descsaldo60,
			descsaldo90,
			descsaldo90mas,
			opt_02,
			deuda_total,
			cedula,
			observacion
			)
			values(
			trim(_no_documento),
			trim(_nombre_asegurado),
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_monto_90mas,
			'A',
			_pagominimo,
			_vigencia_final,
			'Saldo Corriente',
			'Morosidad 30 dias',
			'Morosidad 60 dias',
			'Morosidad 90 dias',
			'Morosidad a mas de 90 dias',
			'  ',
			_saldo,
			trim(_cedula_asegurado),
			' '
			);			
		end if
	end if
end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure;