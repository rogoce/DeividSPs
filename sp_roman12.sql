--Detalle de primas suscritas, correo Roman 27/05/2024
--Armando Moreno M.

drop procedure sp_roman12;
create procedure sp_roman12(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	smallint	as anio_endoso,
			char(20)	as no_documento,
			char(1)     as tipo_poliza,
			char(5)		as no_unidad,               
			char(10)	as cod_contratante,
			char(10)    as placa,
			char(5)		as cod_producto,            
			varchar(50)	as nom_producto,
			date		as fecha_emision,          
			char(20)	as estatus_poliza,
			date		as fecha_cancelacion,
			char(1)		as sexo,
			smallint	as anio_auto,
			varchar(50) as marca,
			varchar(50) as modelo,
			varchar(50) as tipo_vehiculo,
			char(1)     as uso_auto,
			decimal(16,2) as suma_asegurada,
			dec(16,2)	as prima,
			dec(16,2)	as descuento,
			dec(16,2)	as recargo,
			dec(16,2)	as prima_anual,
			dec(16,2)	as prima_suscrita,
			dec(16,2)	as pagado_total,
			dec(16,2)	as pagado_bruto;
			
define v_filtros			char(255);
define _error_desc			varchar(50);
define _nom_subramo,_n_tipo_vehi	varchar(50);
define _nom_producto		varchar(50);
define _n_marca, _n_modelo  varchar(50);
define v_desc_nombre		char(35);
define _estatus				char(20);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _no_poliza,_placa    char(10);
define _cod_contratante		char(10);
define v_nopoliza			char(10);
define _periodo_endoso		char(7);
define _periodo_hasta		char(7);
define _periodo_desde		char(7);
define _cod_producto		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_marca			char(5);
define _cod_modelo			char(5);
define v_noendoso			char(5);
define v_cod_tipoprod		char(3);
define v_cod_sucursal		char(3);
define _cod_subramo,_cod_ramo		char(3);
define v_forma_pago			char(3);
define v_cod_ramo,_cod_tipoveh		char(3);
define s_tipopro			char(3);
define s_cia				char(3);
define _tipo_produccion		char(1);
define _tipo_asegurado		char(1);
define _sexo,_uso_auto    	char(1);
define _tipo,_tipo_poliza	char(1);
define _porc_proporcion		dec(9,6);
define _prima_anual_tot_ase	dec(16,2);
define _prima_anual_total	dec(16,2);
define _prima_susc_anual	dec(16,2);
define _recargo_anual		dec(16,2);
define _pagado_bruto		dec(16,2);
define _recargo,_descuento  dec(16,2);
define _pagado_total		dec(16,2);
define _prima_sus_uni			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_tar,_suma_asegurada	dec(16,2);
define _prima_uni			dec(16,2);
define _estatus_poliza		smallint;
define _anio_endoso			smallint;
define _edad_endoso			smallint;
define _mes_desde			smallint;
define _mes_hasta			smallint;
define _anio,_ano_auto		smallint;
define _dia					smallint;
define _mes					smallint;
define _error_isam			integer;
define _error				integer;
define v_estatus			smallint;
define _fecha_cancelacion	date;
define _fecha_suscripcion	date;
define _fecha_nacimiento	date;
define _fecha_emision_u		date;
define _fecha_efectiva		date;
define _no_activo_desde		date;
define _vigencia_endoso		date;
define _fecha_efect_dep		date;
define _date_added_dep		date;
define _vigencia_desde		date;
define _vigencia_hasta		date;
define _no_activo_dep		date;
define _vigencia_inic		date;
define _vigencia_uni		date;


SET ISOLATION TO DIRTY READ;
begin
on exception set _error, _error_isam, _error_desc
   return _error,'','','','','','',_error_desc,'01/01/1900','','01/01/1900','',0,'','','','',0.00, 0.00,0.00,0.00,0.00,0.00,0.00,0.00;
end exception

drop table if exists tmp_primas_censo;
call sp_roman11(a_periodo_desde,a_periodo_hasta) returning _error,_error_desc;  --Crea tabla tmp_primas_censo

drop table if exists tmp_sinis;
let v_filtros = sp_rec704('001','001',a_periodo_desde,a_periodo_hasta,'*','*','020,002,023;','*','*','*','*','*'); --Crea tabla tmp_sinis

--set debug file to "tarifa_salud_tcn.trc";
--trace on;
foreach
	select tmp.anio,
		   tmp.no_poliza,
		   tmp.no_documento,
		   tmp.no_unidad,
		   tmp.cod_contratante,
		   tmp.cod_producto,
		   tmp.sexo,
		   tmp.tipo_poliza,
		   tmp.placa,
		   tmp.fecha_suscripcion,
		   tmp.ano_auto,
		   tmp.cod_marca,
		   tmp.cod_modelo,
		   tmp.cod_tipoveh,
		   tmp.uso_auto,
		   tmp.suma_asegurada,
		   tmp.prima_uni,
		   tmp.descuento_uni,
		   tmp.recargo_uni,
		   tmp.prima_neta_uni,
		   tmp.prima_sus_uni
	  into _anio,
		   _no_poliza,
		   _no_documento,
		   _no_unidad,
		   _cod_contratante,
		   _cod_producto,
		   _sexo,
		   _tipo_poliza,
		   _placa,
		   _fecha_suscripcion,
		   _ano_auto,
		   _cod_marca,
		   _cod_modelo,
		   _cod_tipoveh,
		   _uso_auto,
		   _suma_asegurada,
		   _prima_uni,
		   _descuento,
		   _recargo,
		   _prima_neta,
		   _prima_sus_uni
	  from tmp_primas_censo tmp
	 order by tmp.anio,tmp.no_documento,tmp.no_unidad,tmp.cod_contratante
	 
	select estatus_poliza,
	       fecha_cancelacion,
		   cod_ramo,
		   cod_subramo
	  into _estatus_poliza,
	       _fecha_cancelacion,
		   _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza in (1,3) then
		let _estatus = 'VIGENTE';
	else
		let _estatus = 'CANCELADA';
	end if
	
	select nombre
	  into _nom_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
       and cod_subramo = _cod_subramo;
  
	select sum(pagado_bruto),
		   sum(pagado_total)
	  into _pagado_bruto,
		   _pagado_total
	  from tmp_sinis tmp
	 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo 
	 inner join rectrmae trx on trx.no_tranrec = tmp.no_tranrec
	 where rec.no_poliza = _no_poliza
	   and rec.no_unidad = _no_unidad
	   and rec.cod_reclamante = _cod_contratante
	   and trx.periodo[1,4]   = _anio
	   and tmp.seleccionado   = 1;
	   
	if _pagado_total is null then
		let _pagado_total = 0.00;
	end if
	
	if _pagado_bruto is null then
		let _pagado_bruto = 0.00;
	end if
	
	select nombre
	  into _n_marca
	  from emimarca
	 where cod_marca = _cod_marca;
	
	select nombre
	  into _n_modelo
	  from emimodel
	 where cod_modelo = _cod_modelo;
	 
	select nombre
	  into _n_tipo_vehi
	  from emitiveh
	 where cod_tipoveh = _cod_tipoveh;
	 
	select nombre
	  into _nom_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	return _anio,
		   _no_documento,
		   _tipo_poliza,
		   _no_unidad,
		   _cod_contratante,
		   _placa,
		   _cod_producto,
		   _nom_producto,
		   _fecha_suscripcion,
		   _estatus,
		   _fecha_cancelacion,
		   _sexo,
		   _ano_auto,
		   _n_marca,
		   _n_modelo,
		   _n_tipo_vehi,
		   _uso_auto,
		   _suma_asegurada,
		   _prima_uni,
		   _descuento,
		   _recargo,
		   _prima_neta,
		   _prima_sus_uni,
		   _pagado_total,
		   _pagado_bruto 
		   with resume;
end foreach
end
end procedure;