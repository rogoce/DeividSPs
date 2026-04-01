-- Cambio del proceso automatico que solo marque en estatus de cancelada 
-- y permita en Deivid seleccionar las polizas a cancelar
-- Creado    : 16/06/2011 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob762;
create procedure sp_cob762(a_user_proceso CHAR(15), a_numero char(10))
returning integer,
          char(100);

define _no_documento	char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);  
define _cobra_poliza	char(1);
define _estatus_poliza	char(1);
define _cod_tipoprod	char(3);

define _cantidad		smallint;
define _fecha_emision	date;
define _fecha_actual	date;

define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _nombre_formapag	char(50);
define _dias			smallint;
define _return			smallint;
define _error			integer;
define _error_isam      integer;
define _error_desc      char(50);

define _cancelada		smallint;
define _fecha_canc		date;
define _fecha_proceso	date;

define _saldo			dec(16,2);
define _saldo_act		dec(16,2);
define _saldo_canc		dec(16,2);
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _corriente		dec(16,2);
define _dias_30  		dec(16,2);
define _dias_60  		dec(16,2);
define _dias_90  		dec(16,2);
define _dias_120 		dec(16,2);
define _dias_150 		dec(16,2);
define _dias_180		dec(16,2);
define _no_aviso 		char(15);
define _user_added		char(8);
define _renglon         integer;
define _descripcion     char(100);

define _tm_ultima_gestion integer;
define _tm_fecha_efectiva integer;
define _activo  integer;
define _realizado integer;
define _li_error integer;
define _ls_mess char(100);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _saldo_canc	 = 0;
let _renglon = 0;
let _fecha_actual = sp_sis26();
let _tm_ultima_gestion = 0;
let _tm_fecha_efectiva = 0;

---set debug file to "sp_cob762.trc";
---trace on;

select activo 
  into _activo 
  from cobccert0 
 where numero = a_numero; 
 
 

foreach
	select no_aviso,fecha_recibo 
	  into _no_aviso,_fecha_canc
	  from cobccert0
	 where numero = a_numero
	   and activo in (1,4)

	foreach
		select distinct no_documento 
		  into _no_documento  
		  from cobccert1  
		 where numero = a_numero  
		   and error in (0) 

		select no_poliza,  
			   renglon  
		  into _no_poliza,  
			   _renglon 
		  from avisocanc 
		 where estatus      = "I"  
		   and no_aviso     = _no_aviso  
		   and no_documento = _no_documento;  		   

--		    let _fecha_canc  = sp_sis26();            

		update avisocanc
		   set estatus         = "M",
			   marcar_entrega  = 1, 
			   fecha_marcar    = _fecha_canc, 
				user_marcar    = a_user_proceso 
		 where no_poliza       = _no_poliza 
		   and no_aviso        = _no_aviso 
		   and renglon         = _renglon;       		   
		   
		if _activo = 4 then 		   								   
		   CALL sp_log018(_no_documento,_no_poliza,_no_aviso,a_user_proceso)
		   RETURNING _error, _error_desc;
		   --RETURNING _li_error,_ls_mess;
	   end if
		   
		   
	end foreach 
end foreach 


 
 if _activo = 4 then   	-- reporte logistica estatus 4 
		   
	  update cobccert1 
		 set error = 3   -- se coloco la fecha al aviso en avisocanc 
	   where numero = a_numero 
		 and error in (0); 
		 
	 select count(*)
	   into _realizado 
	   from cobccert1 
	  where numero = a_numero 
	    and error <> 3;	 
		 
		 if _realizado = 0 then
			  update cobccert0 
				 set usuario_entrega = a_user_proceso, activo = 5   -- completado si se marco como entregado "M"
			   where numero = a_numero ;				 
		 end if
		 
end if

return 0, "Actualizacion Exitosa ...";
end 
end procedure	 
