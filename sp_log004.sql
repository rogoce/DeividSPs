-- Procedimiento que Consulta informacion por Poliza de la caja
-- Creado    : 07/09/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_log004("1811-00084-04")


drop procedure sp_log004;
create procedure sp_log004(a_no_documento char(20)) 
returning char(20),char(10),char(10),char(255),char(50),char(20),char(10);

define _imp_num				char(20);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_hoja				char(10);
define _no_caja				char(10);
define _no_instancia		char(10);
define _texto_imp			char(20);
define _no_factura			char(10);
define _archivada			smallint;
define _date_added			date;
define _user_added 			char(8);
define _origen		    	smallint;
define _filtro          	char(255);
define _c_descripcion		char(50);
define _c_user_added		char(8);
define _c_date_added		date;
define _c_archivada	    	smallint;
define _c_cerrada	        smallint;
define _c_date_archivada	date;
define _c_date_cerrada	    date;
define _c_user_cerrada 	    char(8);

SET ISOLATION TO DIRTY READ;

foreach

	select no_hoja,
	       no_caja,
	       no_instancia,
	       texto_imp,
	       no_factura,
	       archivada,
	       date_added,
	       user_added 
      into _no_hoja,
		   _no_caja,
		   _no_instancia,
		   _texto_imp,
		   _no_factura,
		   _archivada,
		   _date_added,
		   _user_added 
	  from dighoja 
	 where no_documento = a_no_documento -- '1811-00084-04'
	 order by no_hoja,no_caja

		let _filtro = "";

	select descripcion,
	       user_added,
	       date_added,
	       archivada,
	       cerrada,
	       date_archivada,
	       date_cerrada,
	       user_cerrada 
	  into _c_descripcion,	
		   _c_user_added,	
		   _c_date_added,	
		   _c_archivada,	    
		   _c_cerrada,	    
		   _c_date_archivada,
		   _c_date_cerrada,	
		   _c_user_cerrada 	
	  from digcaja 
	 where no_caja = _no_caja;

	if _no_caja is null then
	   let _filtro = 'Sin Asignar Caja.';
	end if

   return a_no_documento,
   		  _no_hoja,
		  _no_caja,
		  _filtro,
		  _c_descripcion,
		  _texto_imp,
		  _no_factura
     with resume;

end foreach

end procedure