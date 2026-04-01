--drop procedure sp_reserva_riesgo_act_serie1;
create procedure sp_reserva_riesgo_act_serie1(a_periodo char(7))
returning integer,varchar(250);

BEGIN

define _error_desc,_mensaje					varchar(250);
define _id_certificado				varchar(25);
define _no_factura				char(10);
define _no_poliza,_no_endoso					char(10);
define _cod_tipoprod				char(3);
define _cod_sucursal        		char(3);
define _cod_endomov					char(3);
define _cod_subramo         		char(3);
define _cod_ramo,_cod_ramo_agrupa   char(3);
define _nueva_renov					char(1);
define _tipo_agente            		char(1);
define _indcol              		char(1);
define _id_mov_tecnico				integer;
define _error_isam					integer;
define _error,_cnt						integer;
define _cod_contrato,_no_unidad		char(5);
define _serie                       smallint;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc); --|| 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

--set debug file to "sp_reserva_riesgo.trc";
--trace on;

set isolation to dirty read;

let _cnt = 0;

foreach
	select id_recibo,
	       id_certificado,
		   serie
	  into _no_factura,
	       _no_unidad,
		   _serie
	  from deivid_ttcorp:reserva_riesgo_c
	 where periodo = a_periodo
  group by id_recibo,id_certificado,serie
 
	update deivid_ttcorp:reserva_riesgo_curso
	   set serie = _serie
	 where periodo        = a_periodo
	   and id_recibo      = _no_factura
	   and id_certificado = _no_unidad;
	
	{let _cnt = _cnt + 1;
	if _cnt = 100 then
		exit foreach;
	end if}
end foreach
return 0, 'Proceso Terminado...';	
end			
end procedure;