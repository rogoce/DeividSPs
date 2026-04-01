-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite11e;

create procedure "informix".sp_emite11e() 
returning	smallint,varchar(200);


define _error_title			varchar(200);
define _error_desc			varchar(200);
define _deducible_colision	varchar(50);
define _deducible_incendio	varchar(50);
define _deducible_robo		varchar(50);
define _asegurado			varchar(50);
define _email				varchar(50);
define _poliza_ant			varchar(30);
define _cedula				varchar(30);
define _no_documento		varchar(20);
define _no_chasis			varchar(30);
define _no_motor			varchar(30);
define _uso_auto			char(30);
define _ruc					char(30);
define _poliza_maestra_auto	char(20);
define _poliza_maestra_tran	char(20);
define _cod_producto		char(10);
define _cod_cliente			char(10);
define _no_poliza_mae		char(10);
define _no_poliza			char(10);
define _estatus				char(10);
define _tipo				char(10);
define _periodo				char(7);
define _asiento				char(7);
define _tomo				char(7);
define _placa				char(6);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _prima_suscrita		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_prd			dec(16,2);
define _impuesto			dec(16,2);
define _error_isam			smallint;
define li_return			smallint;
define _ramo_sis			smallint;
define _ano_auto			smallint;
define _tipo_doc			smallint;
define _cnt_auto			smallint;
define _existe				smallint;
define _error				smallint;

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

foreach
	select feb.no_documento,
		   feb.no_poliza,
		   feb.no_endoso,
		   feb.prima_neta,
		   feb.prima_suscrita,
		   uni.no_unidad,
		   prd.prima
	  into _no_documento,
		   _no_poliza,
		   _no_endoso,
		   _prima_neta,
		   _prima_suscrita,
		   _no_unidad,
		   _prima_prd
	  from endedmae feb
	 inner join endedmae ene on ene.no_poliza = feb.no_poliza and ene.periodo = '2023-02' and ene.cod_endomov = '014'
	 inner join endeduni uni on uni.no_poliza = feb.no_poliza and uni.no_endoso = feb.no_endoso
	 inner join endeduni une on une.no_poliza = ene.no_poliza and une.no_endoso = ene.no_endoso
	 inner join prdtaeda prd on prd.cod_producto = uni.cod_producto
	-- inner join prdtaeda mae on prd.cod_producto = une.cod_producto
	 where feb.cod_endomov = '014'
	   and feb.periodo = '2023-03'
	   and feb.actualizado = 0
	 order by prd.cod_producto

	let _impuesto = _prima_prd * .05;
	let _prima_bruta = _prima_prd + _impuesto;
	
	update endeduni
	   set prima_neta = _prima_prd,
		   prima_retenida = _prima_prd,
		   prima_suscrita = _prima_prd,
		   impuesto = _impuesto,
		   prima = _prima_prd,
		   prima_bruta = _prima_bruta
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedcob
	   set prima_anual = _prima_prd,
		   prima = _prima_prd,
		   prima_neta = _prima_prd
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and prima_neta <> 0;
	   
	update emifacon
	   set prima = _prima_prd
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedmae
	   set prima = _prima_prd,
		   prima_neta = _prima_prd,		   
		   impuesto = _impuesto,
		   prima_bruta = _prima_bruta,
		   prima_retenida = _prima_prd,
		   prima_suscrita = _prima_prd,
		   actualizado = 1
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update endedhis
	   set prima = _prima_prd,
		   prima_neta = _prima_prd,		   
		   impuesto = _impuesto,
		   prima_bruta = _prima_bruta,
		   prima_retenida = _prima_prd,
		   prima_suscrita = _prima_prd
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	return 0, 'Exito. ' ||_no_documento with resume;
end foreach


	return 0,"Actualización Exitosa";
	end
end procedure
