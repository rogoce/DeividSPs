-- pool impresion de renovacion automatica
-- Creado		: 18/05/2009	- Autor: Henry Giron.
-- Modifciado	: 07/02/2012	- Autor: Roman Gordon	**Se Agrego al acreedor para aplicarlo al ordenamiento del datawindow
-- Modifciado	: 04/12/2012	- Autor: Roman Gordon	**Se Agrego el campo de leasing 

drop procedure sp_pro856em1;
create procedure "informix".sp_pro856em1(a_sucursal char(350), a_estatus smallint,a_desde date,a_hasta date,a_acreedor char(5))
	returning 	char(20) as no_documento,
				varchar(50) as n_ramo, 
				char(10) as no_factura,
				varchar(100) as n_cliente,
				varchar(50) as cedula,
				varchar(50) as n_corredor,
				date as vigencia_inic,
				date as vigencia_final;

define _no_documento		char(20); 
define _n_ramo      	    varchar(50);
define _no_factura			char(10); 
define _n_cliente       	varchar(100);
define _cedula     	        varchar(50);
define _n_corredor      	varchar(50);
define _vigencia_inic		date;
define _vigencia_final		date;
define v_filtros       	    varchar(255);


call sp_pro856em(a_sucursal, a_estatus ,a_desde,a_hasta) returning v_filtros;

set isolation to dirty read;

--set debug file to "sp_pro856.trc";
--trace on;

foreach
select  no_documento,   
		n_ramo,
		no_factura,   
		n_cliente,
		cedula,
		n_corredor,
		vigencia_inic,   
		vigencia_final
	into  _no_documento,   
		_n_ramo,
		_no_factura,   
		_n_cliente,
		_cedula,
		_n_corredor,
		_vigencia_inic,   
		_vigencia_final
	from temp_acreedor	
   where cod_acreedor = a_acreedor	
	order by n_ramo,n_cliente
	
		return   _no_documento,   
			_n_ramo,
			_no_factura,   
			_n_cliente,
			_cedula,
			_n_corredor,
			_vigencia_inic,   
			_vigencia_final		
			with resume;
end foreach


end procedure	