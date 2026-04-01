----------------------------------------------------------
--Nota de Cesion facultativa, sacar la fecha de pago
--Creado : 07/09/2017 - Autor: Armando Moreno M.
----------------------------------------------------------
drop procedure sp_sis452a;
create procedure sp_sis452a(a_no_poliza	char(10), a_no_endoso char(10))
returning	date;

define _error_desc			varchar(255);
define v_filtros			varchar(255);
define _nom_contratante		varchar(100);
define _descr_remesa		varchar(100);
define _nom_cober_reas		varchar(50);
define _suma_asegurada		dec(16,2);
define _monto_remesa		dec(16,2);
define _prima				dec(16,2);
define _porc_partic_reas	dec(9,6);
define _porc_comis_fac		dec(9,6);
define _porc_impuesto		dec(5,2);
define _no_chasis			char(30);
define _no_motor			char(30);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_remesa			char(10);
define _no_cesion			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_impuesto		char(3);
define _cod_tipoveh			char(3);
define _cod_descuen			char(3);
define _cod_subramo			char(3);
define _cod_perfac			char(3);
define _cod_color			char(3);
define _cod_ramo			char(3);
define _uso_auto			char(1);
define _tipo				char(1);
define _null				char(1);
define _cant_garantia_pago	smallint;
define _dia_garantia		smallint;
define _iteracion			smallint;
define _no_cambio			smallint;
define _no_pago				smallint;
define _impreso				smallint;
define _orden				smallint;
define _cont				smallint;
define _ano					smallint;
define _mes					smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _fecha_transf_remesa	date;
define _fecha_primer_pago	date;
define _fecha_impresion		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_remesa		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define ldt_vini,ldt_vfin    date;
define _fecha_pago,_fecha_pag_gar date;
define _nombre_cod_coasegur  varchar(50);

--set debug file to "sp_pro383.trc";
--trace on;

--drop table if exists tmp_fecha_pago;

create temp table tmp_fecha_pago(
no_pago		smallint,
fecha_pago	date
) with no log;
  

Select vigencia_inic, 
       vigencia_final
  Into ldt_vini, 
  	   ldt_vfin
  From endedmae
 Where no_poliza = a_no_poliza
   And no_endoso = a_no_endoso;
   
foreach	
		select cant_garantia_pago,
			   cod_perfac,
			   fecha_primer_pago
		  into _cant_garantia_pago,
			   _cod_perfac,
			   _fecha_primer_pago
		  from emifafac
		 where no_poliza		= a_no_poliza
		   and no_endoso		= a_no_endoso
		   and cant_garantia_pago is not null
	exit foreach;
end foreach		   

		if _cant_garantia_pago is null then
			let _cant_garantia_pago = 0;
		end if
		
		select dias
		  into _dia_garantia
		  from reaperfac
		 where cod_perfac = _cod_perfac;

		let _cont = 1;

		for _iteracion = _cont to _cant_garantia_pago
			let _fecha_pago = _fecha_primer_pago + _dia_garantia units day;
			
			insert into tmp_fecha_pago(
					no_pago,
					fecha_pago)
			values(	_iteracion,
					_fecha_pago);

			let _fecha_primer_pago = _fecha_pago; 
		end for

let _fecha_pago = null;
foreach
	select fecha_pago
	  into _fecha_pago
	  from tmp_fecha_pago
	  
	return _fecha_pago with resume;
end foreach			  
end procedure;