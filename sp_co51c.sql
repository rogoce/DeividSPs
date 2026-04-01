-- encabezado de los estados de cuenta por cliente y morosidad	(todas las polizas, incluyendo saldo 0)
-- creado por :     marquelda valdelamar 26/09/2001
-- modificado por:	marquelda valdelamar 04/07/2002
-- sis v.2.0 - deivid, s.a.

drop procedure sp_co51c;

create procedure "informix".sp_co51c(
a_compania		char(3),
a_sucursal		char(3),
a_cod_cliente	char(10),
a_fecha_desde	date,
a_fecha_hasta	date,
a_cod_ramo		char(100),
a_user			char(8)	  
) returning	date,       -- vigencia_inic
			date,       -- vigencia_final
			char(50),   -- nombre_ramo
			char(50),   -- nombre_subramo
			char(50),   -- nombre_agente
			char(50),	-- nombre_cliente
			char(100),	-- direccion1
			char(100),  -- direccion2
			char(20),   -- telefono1
			char(20),	-- telefono2
			char(10),   -- apartado
			char(20),	-- no_documento
			char(10),   -- no_poliza
			char(30),   -- estatus de la poliza
		  	date,       -- fecha de cancelacion
		  	dec(16,2),	-- por vencer
		  	dec(16,2),	-- exigible
		  	dec(16,2),	-- corriente
		  	dec(16,2),	-- monto 30
		  	dec(16,2),  -- monto 60
		  	dec(16,2), 	-- monto 60
			dec(16,2),	-- saldo
			char(7),	-- periodo
			char(50),	-- forma de pago
			char(8),
			char(50),
			char(50),
			char(20),
			char(50);

define _direccion1			char(100);
define _direccion2			char(100);
define _nombre_cliente		char(50);
define _nombre_subramo		char(50);
define _nombre_agente		char(50);
define _nom_formapag		char(50);
define _nombre_ramo			char(50);
define _aseg_lider			char(50);
define _compania			char(50);
define _estatus				char(30);
define _no_documento		char(20);
define _telefono1			char(20);
define _telefono2			char(20);
define _cod_contr_act		char(10);
define _no_poliza			char(10);
define _apartado			char(10);
define _periodo_vig_fin		char(7);
define _periodo2			char(7);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_coasegur		char(3);
define _tmp_codramo			char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _tipo				char(1);
define _por_vencer			dec(16,2);
define _exigible			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _saldo				dec(16,2);
define v_prima_orig			dec(16,2);
define _por_vencer_tot		dec(16,2);
define _exigible_tot		dec(16,2);
define _corriente_tot		dec(16,2);
define _monto_30_tot		dec(16,2);
define _monto_60_tot		dec(16,2);
define _monto_90_tot		dec(16,2);
define _saldo_tot			dec(16,2);
define _flag				smallint;
define _estatus_poliza		integer;
define _fecha_cancelacion	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _celular			    char(20);
define _cod_asegurado       char(10);
define _asegurado           char(50);
define _cnt                 integer;

set isolation to dirty read;

--set debug file to "sp_co51c.trc";
--trace on;
--encabezado del estado de cuenta

let _aseg_lider		= "";
let _estatus		= "";
let _estatus_poliza	= 0;
let _por_vencer_tot	= 0.00;
let _corriente_tot	= 0.00;
let _monto_30_tot	= 0.00;
let _monto_60_tot	= 0.00;
let _monto_90_tot	= 0.00;
let _exigible_tot	= 0.00;
let _saldo_tot		= 0.00;
let _flag			= 0;
let _cnt            = 0;
 
call sp_sis39(a_fecha_hasta) returning _periodo2;
call sp_sis39(a_fecha_desde) returning _periodo;
call sp_sis01(a_compania)	 returning _compania;

-- proceso para buscar si se requiere un estado de cuenta de algun ramo en especifico

if a_cod_ramo <> "*" then
	let _tipo = sp_sis04(a_cod_ramo);  -- separa los valores del string en una tabla de codigos
else
	let a_cod_ramo = ';';
	foreach
		select cod_ramo
		  into _tmp_codramo
		  from prdramo

		if _flag = 0 then
			let a_cod_ramo = _tmp_codramo || a_cod_ramo;
			let _flag = 1;
		else
			let a_cod_ramo = _tmp_codramo || ',' || a_cod_ramo;
		end if
	end foreach
	let _tipo = sp_sis04(a_cod_ramo);  -- separa los valores del string en una tabla de codigos	   
end if

-- seleccion del tipo de produccion
select cod_tipoprod
  into _cod_tipoprod
  from emitipro
 where tipo_produccion = 4;	-- reaseguro asumido

-- datos del cliente
select nombre,
       direccion_1,
	   direccion_2,
	   telefono1,
	   telefono2,
	   apartado,
	   celular
 into  _nombre_cliente,
       _direccion1,
	   _direccion2,
	   _telefono1,
	   _telefono2,
	   _apartado,
	   _celular
 from  cliclien
where cod_cliente = a_cod_cliente;

-- datos de la poliza
foreach
	select no_documento
	  into  _no_documento
	  from emipomae
	 where cod_contratante = a_cod_cliente
	   and actualizado  = 1
	   and cod_tipoprod <> _cod_tipoprod 	-- reaseguro asumido
	   and cod_ramo in (select codigo from tmp_codigos)
	 group by no_documento

	call sp_sis21(_no_documento) returning _no_poliza;

	select cod_contratante
	  into _cod_contr_act
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_contr_act <> a_cod_cliente then
		continue foreach;
	end if

	-- datos de la poliza
	foreach
		select vigencia_inic,
			   vigencia_final,
			   cod_ramo,
			   cod_subramo,
			   estatus_poliza,
			   fecha_cancelacion,
			   no_poliza,
			   cod_formapag
		 into  _vigencia_inic,
			   _vigencia_final,
			   _cod_ramo,
			   _cod_subramo,
			   _estatus_poliza,
			   _fecha_cancelacion,
			   _no_poliza,
			   _cod_formapag
		  from emipomae
	     where no_documento = _no_documento   
		 order by 1 desc
		exit foreach;
	end foreach
	
	call sp_sis39(_vigencia_final) returning _periodo_vig_fin;
	
	if a_fecha_desde = a_fecha_hasta then
		call sp_sis39(_vigencia_inic) returning _periodo;
	end if
	 
	if _periodo_vig_fin < _periodo then
		continue foreach;
	end if

	select cod_coasegur 
	  into _cod_coasegur
	  from emicoami
	 where no_poliza = _no_poliza;

	let _aseg_lider = '';

	if _cod_coasegur is not null then
		select nombre
		  into _aseg_lider
		  from emicoase
		 where cod_coasegur = _cod_coasegur;
	end if
	 
--morosidad total
	call sp_cob33d(a_compania,a_sucursal,_no_documento,_periodo2,a_fecha_hasta) 
	returning _por_vencer,
			  _exigible,
			  _corriente,
			  _monto_30,
			  _monto_60,
			  _monto_90,
			  _saldo;

	let _por_vencer_tot	= _por_vencer_tot + _por_vencer;
	let _exigible_tot	= _exigible_tot   + _exigible;
	let _corriente_tot	= _corriente_tot  + _corriente;
	let _monto_30_tot	= _monto_30_tot   + _monto_30;
	let _monto_60_tot	= _monto_60_tot   + _monto_60;
	let _monto_90_tot	= _monto_90_tot   + _monto_90;
	let _saldo_tot		= _saldo_tot      + _saldo;

	if _estatus_poliza = 1 then
		let _estatus = 'vigente';
	elif _estatus_poliza = 2 then
	    let _estatus = 'cancelada';
	elif _estatus_poliza = 3 then
	    let _estatus = 'vencida';
	else
	    let _estatus = 'anulada';
	end if

-- ramo y subramo
	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;	

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

-- agente de la poliza
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		exit foreach;
	end foreach

	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	if _cnt > 1 then
		let _asegurado = 'Ver Detalle de Unidades';
	elif _cnt = 1 then
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;
	else	
		let _asegurado = _nombre_cliente;
	end if

	return 	_vigencia_inic,
			_vigencia_final,
			_nombre_ramo,
			_nombre_subramo,
			_nombre_agente,
			_nombre_cliente,
			_direccion1,
			_direccion2,
			_telefono1,
			_telefono2,
			_apartado,
			_no_documento,
			_no_poliza,
			_estatus,
			_fecha_cancelacion,
			_por_vencer_tot,
			_exigible_tot,
			_corriente_tot,
			_monto_30_tot,
			_monto_60_tot,
			_monto_90_tot,
			_saldo_tot,
			_periodo2,
			_nom_formapag,
			a_user,
			_compania,
			_aseg_lider,
			_celular,
			_asegurado
		   	with resume;

end foreach
drop table tmp_codigos;
end procedure;

