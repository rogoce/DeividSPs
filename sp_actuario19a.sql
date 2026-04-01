
drop procedure sp_actuario19a;
create procedure "informix".sp_actuario19a()
	returning integer,varchar(250);

BEGIN
define _error_desc			varchar(250);
define _cod_usuario			varchar(30);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _mto_comision		dec(18,2);
define _mto_reserva			dec(18,2);
define _mto_prima			dec(18,2);
define _mto_suma			dec(18,2);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_ramo_ttcorp		smallint;
define _id_mov_tecnico		integer;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea			smallint;
define _cod_empresa			smallint;
define _num_serie			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _tipo_produccion     smallint;

define _tiene_impuesto		smallint;
define _id_relac_productor	integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _error				integer;
define _fec_situacion		date;
define _fec_operacion		date;
define _fec_registro		date;
define _fec_emision			date;
define _fec_inivig			date;
define _fec_finvig			date;
define _cod_sucursal        char(3);

on exception set _error,_error_isam,_error_desc
    ROLLBACK WORK;
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _id_poliza;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19.trc";
--trace on;

set isolation to dirty read;

let _fec_operacion	= today;
let _fec_registro	= today;
let _mto_reserva	= 0.00;
let _id_mov_tecnico = 0;
let _cod_situacion	= 5;	--13 para prima cobrada
let _cod_empresa	= 11;
let _por_tasa		= 1;
let _cod_moneda		= 'USD';


BEGIN WORK;

foreach with hold
	select id_mov_tecnico,                        
		   id_poliza,
		   id_recibo
	  into _id_mov_tecnico,                        
		   _id_poliza,
		   _id_recibo
	  from movim_tec_pri_ttco
--	 where tip_poliza = 2

   foreach	
	select no_poliza
	  into _no_poliza
	  from endedmae
	 where no_factura   = _id_recibo
	   and no_documento = _id_poliza
	exit foreach;
   end foreach
	   
	select cod_tipoprod,tiene_impuesto
	  into _cod_tipoprod,_tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	 select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;
	 
	 

	update movim_tec_pri_ttco
	   set tipo_produccion = _tipo_produccion,
	       tipo_impuesto   = _tiene_impuesto 
	 where id_mov_tecnico  = _id_mov_tecnico;


 {	if  _cod_grupo in ('00000','1000') then
		update movim_tec_pri_ttco
		   set tip_poliza = 5
		 where id_mov_tecnico = _id_mov_tecnico;
	end if

	foreach
		select id_mov_reas
		  into _id_mov_reas
		  from movim_reaseguro_pr
		 where id_mov_tecnico = _id_mov_tecnico

		delete from reas_caract_pri
		 where id_mov_reas = _id_mov_reas;
	end foreach
	
	delete from movim_reaseguro_pr
	 where id_mov_tecnico = _id_mov_tecnico;
	 
	call sp_actuario20(_id_mov_tecnico,_id_mov_tecnico) returning _error,_error_desc;
	
	foreach
		select id_mov_reas
		  into _id_mov_reas
		  from movim_reaseguro_pr
		 where id_mov_tecnico = _id_mov_tecnico
		
		call sp_actuario21(_id_mov_reas,_id_mov_reas) returning _error,_error_desc;
	end foreach}
end foreach

COMMIT WORK;
return 0,'Inserción Exitosa';	
end			
end procedure 
