-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 25/11/2009 - Autor: Amado Perez.
-- 15/10/2010 - Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo 
-- 10/04/2011 - Modificado - Autor: Henry: Arlena Gomez , tomar la parte de terremoto no se estaba calculando.
-- execute procedure sp_rea24("001","001","2010-12")

drop procedure sp_rea062;
create procedure "informix".sp_rea062(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
returning integer,
          char(50);

{
returning CHAR(3),                  
		  varchar(50),                              
		  char(20),                 
		  DEC(16,2),               
		  DEC(16,2),               
		  DEC(16,2),               
		  DEC(16,2),               
		  CHAR(7),
		  char(3),
		  char(50);                 
}		  
define _error			   integer;
define _descripcion        char(50);
define _fecha              date;
define _cod_coasegur       char(3);
define _no_poliza		   char(10);
define _no_poliza_1        char(10);
define _saldo_act          dec(16,2);
define _saldo_ant          dec(16,2);
define _porc_partic_prima  dec(9,2);
define _porc_partic_reas   dec(9,6);
define _saldo_reaseg       dec(16,2);
define _comision      	   dec(16,2);
define _impuesto           dec(16,2);
define _doc_poliza         char(20);     
define _cod_ramo           char(3);
define _cod_contratante    char(10);
define _vigencia_inic      date;
define _vigencia_final     date;
define _nombre             varchar(50);
define _nombre_reas        varchar(50);
define _nombre_contratante varchar(100);
define _periodo            varchar(7);
define _debito             dec(16,2);
define _credito            dec(16,2);
define _debito_final       dec(16,2);
define _credito_final      dec(16,2);
define _monto_tran         dec(16,2); 
define _diferencia_saldo   dec(16,2);
define _suma_total         	dec(16,2);
define _mes					smallint;
define _ano    	     		smallint;
define _no_registro     	char(10);
define _cod_auxiliar		char(5);
define _cantidad			smallint;


let _diferencia_saldo	= 0;
let _saldo_ant        	= 0;
let _credito_final    	= 0;
let _debito_final     	= 0;

foreach
 select no_documento,
         cod_coasegur,
		saldo_ante
   into _cantidad
   from rea_saldo
  where no_documento	= _doc_poliza
    and cod_coasegur 	= _cod_coasegur
    and periodo      	= a_periodo;

			
--	let _diferencia_saldo = _saldo_ant - _saldo_reaseg;
	--let _suma_total = _monto_tran - _diferencia_saldo;
		
end foreach

return 0, "Actualizacion Exitosa";

{
	return _cod_coasegur,                                    
	       _nombre_reas,                                                                             
		   _doc_poliza,                                       
		   _saldo_ant,	                                     
		   _saldo_reaseg,                                      
		   _diferencia_saldo,                               
		   _monto_tran,                                   
		   _periodo,
		   _cod_ramo,
		   _nombre WITH RESUME;                           
}

end procedure