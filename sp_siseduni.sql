-- Creado     : 11/09/2007 - Autor: Ruben Arnaez 

--DROP PROCEDURE sp_siseduni;

create procedure "informix".sp_siseduni(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user			char(8))
 returning integer,
           char(100);

{
define _tiempo	datetime year to fraction(5);
define _error	integer;
let _tiempo = current;
}


-- Para cargar la tabla temporal de ENDEDUNI
define dno_poliza            char(10);
define dno_endoso            char(5);
define dno_unidad            char(5);
define dcod_ruta             char(5);
define dcod_producto         char(5);
define dcod_cliente          char(10),
define dsuma_asegurada       decimal(16,2);
define dprima                decimal(16,2);
define ddescuento            decimal(16,2);
define drecargo              decimal(16,2);
define dprima_neta           decimal(16,2);
define dimpuesto             decimal(16,2);
define dprima_bruta          decimal(16,2);
define dreasegurada          smallint;
define dvigencia_inic        date;
define dvigencia_final       date;
define dbeneficio_max        decimal(16,2);
define ddesc_unidad          varchar(50,0);
define dprima_suscrita       decimal(16,2);
define dprima_retenida       decimal(16,2);
define dsuma_aseg_adic       decimal(16,2);
define dtipo_incendio        smallint;
define dgastos               decimal(16,2);

	  
DEFINE _usuario       char(8);  -- 1
DEFINE _descripcion   char(30); -- 2
DEFINE _e_mail        char(30); -- 3 
DEFINE _status        char(1);  -- 4
DEFINE _windows_user  char(20); -- 5
DEFINE _fvac_out      date;	    -- 6
DEFINE _fvac_duein    date;	    -- 7

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE temp_endeduni(
no_poliza            char(10),
no_endoso            char(5),
no_unidad            char(5),
cod_ruta             char(5),
cod_producto         char(5),
cod_cliente          char(10),
suma_asegurada       decimal(16,2),
prima                decimal(16,2),
descuento            decimal(16,2),
recargo              decimal(16,2),
prima_neta           decimal(16,2),
impuesto             decimal(16,2),
prima_bruta          decimal(16,2),
reasegurada          smallint,
vigencia_inic        date,
vigencia_final       date,
beneficio_max        decimal(16,2),
desc_unidad          varchar(50,0),
prima_suscrita       decimal(16,2),
prima_retenida       decimal(16,2),
suma_aseg_adic       decimal(16,2),
tipo_incendio        smallint,
gastos               decimal(16,2)
--- PRIMARY KEY		(cod_asegurado)
	) WITH NO LOG;	

foreach 
	  
	select	no_poliza            , 
			no_endoso            ,
			no_unidad            ,
			cod_ruta             ,
			cod_producto         ,
			cod_cliente          ,
			suma_asegurada       ,
			prima                ,
			descuento            ,
			recargo              ,
			prima_neta           ,
			impuesto             ,
			prima_bruta          ,
			reasegurada          ,
			vigencia_inic        ,
			vigencia_final       ,
			beneficio_max        ,
			desc_unidad          ,
			prima_suscrita       ,
			prima_retenida       ,
			suma_aseg_adic       ,
			tipo_incendio        ,
			gastos               
		into 
	     	dno_poliza            ,
			dno_endoso            ,
			dno_unidad            ,
			dcod_ruta             ,
			dcod_producto         ,
			dcod_cliente          ,
			dsuma_asegurada       ,
			dprima                ,
			ddescuento            ,
			drecargo              ,
			dprima_neta           ,
			dimpuesto             ,
			dprima_bruta          ,
			dreasegurada          ,
			dvigencia_inic        ,
			dvigencia_final       ,
			dbeneficio_max        ,
			ddesc_unidad          ,
			dprima_suscrita       ,
			dprima_retenida       ,
			dsuma_aseg_adic       ,
			dtipo_incendio        ,
			dgastos               
		  from endeduni
		  where cod_asegurado = a_cod_errado
	  	
		INSERT INTO temp_endeduni(
		    no_poliza            , 
			no_endoso            ,
			no_unidad            ,
			cod_ruta             ,
			cod_producto         ,
			cod_cliente          ,
			suma_asegurada       ,
			prima                ,
			descuento            ,
			recargo              ,
			prima_neta           ,
			impuesto             ,
			prima_bruta          ,
			reasegurada          ,
			vigencia_inic        ,
			vigencia_final       ,
			beneficio_max        ,
			desc_unidad          ,
			prima_suscrita       ,
			prima_retenida       ,
			suma_aseg_adic       ,
			tipo_incendio        ,
			gastos        
		  )
   VALUES(
		    dno_poliza            ,
			dno_endoso            ,
			dno_unidad            ,
			dcod_ruta             ,
			dcod_producto         ,
			dcod_cliente          ,
			dsuma_asegurada       ,
			dprima                ,
			ddescuento            ,
			drecargo              ,
			dprima_neta           ,
			dimpuesto             ,
			dprima_bruta          ,
			dreasegurada          ,
			dvigencia_inic        ,
			dvigencia_final       ,
			dbeneficio_max        ,
			ddesc_unidad          ,
			dprima_suscrita       ,
			dprima_retenida       ,
			dsuma_aseg_adic       ,
			dtipo_incendio        ,
			dgastos             
		   );
end foreach;
return 0, "Actualizacion Exitosa";
				--execute procedure sp_sisra("1234567890","1234567890","12345678") 
			   	{return  _usuario,	   		-- 1. Usuario 
			   			_descripcion,	   	-- 2. Nombre completo del usuario
						_e_mail,     		-- 3. Correo del usuario 
						_status,	   	    -- 4. Estado del usuario 
						_windows_user,		-- 5. Usuario de windows
						_fvac_out,			-- 6. Fecha inicial de vacaciones 
						_fvac_duein	     	-- 7. fecha de regreso de Vacaciones 
				 }		
	 -- with resume;

end procedure;
