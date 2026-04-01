-- pool renovacion automatica
-- Creado    : 15/05/2009 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro335;
CREATE PROCEDURE sp_pro335(a_no_documento char(20) DEFAULT NULL)
returning char(8),		 
		  date,			  
		  date,			    
		  smallint,		    
		  smallint,
		  char(20),
		  char(1);

define _no_poliza	    char(10);	 
define _cod_contratante char(10);	 
define _prima_bruta	    dec(16,2);	 
define _user_added   	char(8);
define _cod_no_renov   	char(3);
define _no_documento	char(20);
define _renovar   		smallint;
define _no_renovar		smallint;
define _fecha_selec		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _saldo			dec(16,2);
define _cant_reclamos	smallint;
define _no_factura		char(10);
define _incurrido		dec(16,2);
define _pagos   		dec(16,2);
define _porc_depreciacion  dec(5,2);
define _cod_agente  	char(5);
define _saldo_porc      integer;
define _n_cliente       varchar(100);
define _n_corredor      varchar(50);
define _diezporc      	dec(16,2);
define _fecha_hoy       date;
define _dias,_cnt       integer;
define _estatus  		smallint;
define _user_cobros     char(8);

let _fecha_hoy = current;

SET ISOLATION TO DIRTY READ;

if a_no_documento is null or trim(a_no_documento) = "" then
    return "","","",0,1,"","0";
end if

let _cnt = 0;

select count(*)
  into _cnt
  from emirepo
 where no_documento = a_no_documento;

if _cnt is null then
	let _cnt = 0;
end if

if _cnt > 0 then
	FOREACH WITH HOLD	   --> Amado 21/09/2010: Agregue este forach porque daba error de subquery
	    SELECT no_poliza,   
			   user_added,   
			   cod_no_renov,   
			   no_documento,   
			   renovar,   
			   no_renovar,   
			   fecha_selec,   
			   vigencia_inic,   
			   vigencia_final,   
			   saldo,   
			   cant_reclamos,   
			   no_factura,   
			   incurrido,   
			   pagos,   
			   porc_depreciacion,   
			   cod_agente,
			   estatus,
			   user_cobros  
		  INTO _no_poliza,
			   _user_added,   
			   _cod_no_renov,   
			   _no_documento,   
			   _renovar,   
			   _no_renovar,   
			   _fecha_selec,   
			   _vigencia_inic,   
			   _vigencia_final,   
			   _saldo,   
			   _cant_reclamos,   
			   _no_factura,   
			   _incurrido,   
			   _pagos,   
			   _porc_depreciacion,
			   _cod_agente,
			   _estatus,
			   _user_cobros
			FROM emirepo
		   WHERE no_documento = a_no_documento
		ORDER BY no_poliza desc

	   if _user_added = "" then
			let _user_added = _user_cobros;
	   end if

	   return _user_added,_vigencia_inic,_vigencia_final,_estatus,0,a_no_documento,"0" with resume;
	   exit foreach;
    END FOREACH	       
else
	select count(*)
	  into _cnt
	  from emirepol
	 where no_documento = a_no_documento;
	 
	if _cnt is null then
		let _cnt = 0;
	end if

	if _cnt > 0 then
  		FOREACH WITH HOLD  --> Amado 21/09/2010: Agregue este forach porque daba error de subquery
		  SELECT no_poliza,   
		         user_added,   
		         cod_no_renov,   
		         no_documento,   
		         renovar,   
		         no_renovar,   
		         fecha_selec,   
		         vigencia_inic,   
		         vigencia_final,   
		         saldo,   
		         cant_reclamos,   
		         no_factura,   
		         incurrido,   
		         pagos,   
		         porc_depreciacion,   
		         cod_agente,
		         estatus
			INTO _no_poliza,
				 _user_added,   
				 _cod_no_renov,   
				 _no_documento,   
				 _renovar,   
				 _no_renovar,   
				 _fecha_selec,   
				 _vigencia_inic,   
				 _vigencia_final,   
				 _saldo,   
				 _cant_reclamos,   
				 _no_factura,   
				 _incurrido,   
				 _pagos,   
				 _porc_depreciacion,
				 _cod_agente,
				 _estatus
		    FROM emirepol
		   WHERE no_documento = a_no_documento
		ORDER BY no_poliza desc

		return _user_added,_vigencia_inic,_vigencia_final,_estatus,0,a_no_documento,"0" with resume;
	   	exit foreach;
   		END FOREACH	
   	else       					  --> Amado 21/09/2010: puse este else 
		return "","","",0,1,"","0";   	
	end if
end if
END PROCEDURE
