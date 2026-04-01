-- POLIZAS VIGENTES POR RAMO - Diario de Marcacion Actualizacion de CLIENTEVIP  *** HGIRON 02/06/2017
-- SIS v.2.0 - DEIVID, S.A.
-- EXECUTE PROCEDURE sp_pro4962('001','001','02/06/2017','*')

   DROP procedure sp_pro4962;
   CREATE procedure sp_pro4962(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE, a_codramo char(255) default "*")
   returning integer, char(50), char(100);   
			 
    DEFINE v_contratante                    	 CHAR(10);    	
	DEFINE v_prima_suscrita,v_suma_asegurada   	 DECIMAL(16,2);
    DEFINE v_asegurado                			 CHAR(45);
	DEFINE no_documento               			 CHAR(20);	
	DEFINE v_descr_cia                           CHAR(50);
	DEFINE v_filtros          					 CHAR(255);
	DEFINE _cod_categoria                        CHAR(1);
	DEFINE _cod_categoria_ant                    CHAR(1);
	DEFINE _tipo_persona                         CHAR(1);	
	define v_cod_tipoprod		                 char(3);
	define _tipo_produccion		                 Smallint;	
	define _error								 integer;
    define _error_isam							 integer;
	define _error_desc							 varchar(50);	
	define _VIP_all, _VIP_new		             Smallint;	
	define _VIP_desc							 varchar(100);
	
    LET v_descr_cia      = NULL;
	LET no_documento     = NULL;
	LET v_contratante    = NULL;
	LET v_prima_suscrita = 0.00;
	LET _cod_categoria   = '';
	LET _cod_categoria_ant   = '';
	LET v_filtros        = '';	
	LET _tipo_persona    = '';	
	let v_cod_tipoprod   = null;
	let _VIP_all = 0;
    let _VIP_new = 0;	
	let _VIP_desc = "";

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_desc, _error_desc;
end exception

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

    FOREACH
       SELECT y.no_documento,
              y.cod_contratante,
              y.prima_suscrita,
			  Y.cod_tipoprod
         INTO no_documento,
              v_contratante,
              v_prima_suscrita,
			  v_cod_tipoprod
         FROM temp_perfil y
        WHERE y.seleccionado = 1
     ORDER BY y.no_documento
	 
		select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = v_cod_tipoprod;	 

       SELECT nombre,tipo_persona
         INTO v_asegurado, _tipo_persona
         FROM cliclien
        WHERE cod_cliente = v_contratante;					  
		
		if _tipo_persona in ('N','J') then 			  
		
		{begin
		on exception in(-535)
		end exception 	
			begin work;
		end}
		
		BEGIN
			ON EXCEPTION IN(-239,-268)

			END EXCEPTION
			insert into cliviprpt(
					cod_cliente,
					tipo_persona,
					no_documento,
					prima_suscrita,
					tipo_produccion)
			values(v_contratante,
					_tipo_persona,
					no_documento,
					v_prima_suscrita,
					_tipo_produccion);
		END	


			
		end if		
		--commit work;		 
    END FOREACH
	
--  Persona Natural
--  Categoría Silver $5,000.00 hasta $15,000.00- Actualmente contamos con 65 clientes
--  Categoría Gold $15,000.00 en adelante- Actualmente contamos con 25 clientes

--  Persona Jurídica
--  Categoría Silver $10,000.00 hasta $45,000.00- Actualmente contamos con 240 clientes
--  Categoría Gold $45,000.00 en adelante- Actualmente contamos con 248 clientes
--  Se exluye Polizas con Coaseguro Minoritario
	
 FOREACH
       SELECT cod_cliente,
				tipo_persona,
				sum(prima_suscrita)
         INTO v_contratante,
				_tipo_persona,
				v_prima_suscrita
         FROM cliviprpt
	    WHERE tipo_produccion <> 3
     GROUP BY cod_cliente,
			  tipo_persona
			  
		let _cod_categoria = " ";   
	
		if _tipo_persona = 'N' and v_prima_suscrita >= 15000 then 
			let _cod_categoria = "G"; 
		elif _tipo_persona = 'N' and v_prima_suscrita < 15000 and v_prima_suscrita >= 5000 then 
			let _cod_categoria = "S"; 
		elif _tipo_persona = 'J' and v_prima_suscrita >= 45000 then 
			let _cod_categoria = "G";	
		elif _tipo_persona = 'J' and v_prima_suscrita < 45000 and v_prima_suscrita >= 10000 then  
			let _cod_categoria = "S";     			
	   end if 
		
		if _cod_categoria in ('G','S') then  		
		 
		{begin
		on exception in(-535)
		end exception 	
			begin work;
		end	}
		
			begin
		on exception in(-239,-268)
		  select cod_categoria
		    into _cod_categoria_ant
			from clivip
		   where cod_cliente = v_contratante;
		   
		   if _cod_categoria_ant <> _cod_categoria then
				update clivip
				   set cod_categoria = _cod_categoria,
					user_changed = 'DEIVID',
					date_changed = current
				 where cod_cliente = v_contratante;			 
		 end if

		end exception 	
	
			insert into clivip(
				cod_cliente,
				cod_categoria,
				cod_usuario,
				user_added,
				date_added)
			values(v_contratante,
				_cod_categoria,
				null,
				'DEIVID',
				current);
				
--				commit work;
			end
				
		end if

    END FOREACH	
DROP TABLE temp_perfil;
--DROP TABLE cliviprpt;	
delete from cliviprpt;


foreach
 select cod_categoria,count(*) 
   into _cod_categoria,_VIP_all
   from clivip
  group by 1  
  
    if _VIP_desc = "" then
	    let _VIP_desc = "";
	    let _VIP_desc = _cod_categoria||": "||_VIP_all||" ";
	else
		let _VIP_desc = _VIP_desc ||", " ||_cod_categoria||": "||_VIP_all||" ";
	end if
	let _VIP_all = 0;
    
end foreach

return 0,'Actualización Exitosa',_VIP_desc;
END
END PROCEDURE;
