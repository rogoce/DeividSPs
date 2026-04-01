-- Creado     : 11/09/2007 - Autor: Ruben Arnaez 

DROP PROCEDURE sp_sisuni;

create procedure "informix".sp_sisuni(
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


-- Para cargar la tabla temporal de EMIPOUNI
define uno_poliza            char(10);
define uno_unidad            char(5);
define ucod_ruta             char(5);
define ucod_producto         char(5);
define ucod_asegurado        char(10);
define usuma_asegurada       decimal(16,2);
define uprima                decimal(16,2);
define udescuento            decimal(16,2);
define urecargo              decimal(16,2);
define uprima_neta           decimal(16,2);
define uimpuesto             decimal(16,2);
define uprima_bruta          decimal(16,2);
define ureasegurada          smallint;
define uvigencia_inic        date;
define uvigencia_final       date;
define ubeneficio_max        decimal(16,2);
define udesc_unidad          varchar(50);
define uactivo               smallint;
define uprima_asegurado      decimal(16,2);
define uprima_total          decimal(16,2);
define uno_activo_desde      date;
define ufacturado            smallint;
define uuser_no_activo       char(8);
define uperd_total           smallint;
define uimpreso              smallint;
define ufecha_emision        date;
define uprima_suscrita       decimal(16,2);
define uprima_retenida       decimal(16,2);
define ueliminada            smallint;
define usuma_aseg_adic       decimal(16,2);
define utipo_incendio        smallint;
define uprima_vida           decimal(16,2);
define uprima_vida_orig      decimal(16,2);
define ugastos               decimal(16,2);
define udoble_cob            smallint;
define udoble_cob_cia        char(3);
define udoble_cob_fecha      date;
define ucont_beneficios      smallint;
define ucod_doctor           char(10);
define ucambiar_tarifas      smallint;
define usubir_bo             smallint;
	   

	  
DEFINE _usuario       char(8);  -- 1
DEFINE _descripcion   char(30); -- 2
DEFINE _e_mail        char(30); -- 3 
DEFINE _status        char(1);  -- 4
DEFINE _windows_user  char(20); -- 5
DEFINE _fvac_out      date;	    -- 6
DEFINE _fvac_duein    date;	    -- 7

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE temp_emipouni(
no_poliza            char(10),
no_unidad            char(5),
cod_ruta             char(5),
cod_producto         char(5),
cod_asegurado        char(10),
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
activo               smallint,
prima_asegurado      decimal(16,2),
prima_total          decimal(16,2),
no_activo_desde      date,
facturado            smallint,
user_no_activo       char(8),
perd_total           smallint,
impreso              smallint,
fecha_emision        date,
prima_suscrita       decimal(16,2),
prima_retenida       decimal(16,2),
eliminada            smallint,
suma_aseg_adic       decimal(16,2),
tipo_incendio        smallint,
prima_vida           decimal(16,2),
prima_vida_orig      decimal(16,2),
gastos               decimal(16,2),
doble_cob            smallint,
doble_cob_cia        char(3),
doble_cob_fecha      date,
cont_beneficios      smallint,
cod_doctor           char(10),
cambiar_tarifas      smallint,
subir_bo             smallint
--- PRIMARY KEY		(cod_asegurado)
	) WITH NO LOG;	



-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
	  
	select	no_poliza            ,
			no_unidad            ,
			cod_ruta             ,
			cod_producto         ,
			cod_asegurado        ,
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
			activo               ,
			prima_asegurado      ,
			prima_total          ,
			no_activo_desde      ,
			facturado            ,
			user_no_activo       ,
			perd_total           ,
			impreso              ,
			fecha_emision        ,
			prima_suscrita       ,
			prima_retenida       ,
			eliminada            ,
			suma_aseg_adic       ,
			tipo_incendio        ,
			prima_vida           ,
			prima_vida_orig      ,
			gastos               ,
			doble_cob            ,
			doble_cob_cia        ,
			doble_cob_fecha      ,
			cont_beneficios      ,
			cod_doctor           ,
			cambiar_tarifas      ,
			subir_bo             
		into 
	     	uno_poliza            ,
			uno_unidad            ,
			ucod_ruta             ,
			ucod_producto         ,
			ucod_asegurado        ,
			usuma_asegurada       ,
			uprima                ,
			udescuento            ,
			urecargo              ,
			uprima_neta           ,
			uimpuesto             ,
			uprima_bruta          ,
			ureasegurada          ,
			uvigencia_inic        ,
			uvigencia_final       ,
			ubeneficio_max        ,
			udesc_unidad          ,
			uactivo               ,
			uprima_asegurado      ,
			uprima_total          ,
			uno_activo_desde      ,
			ufacturado            ,
			uuser_no_activo       ,
			uperd_total           ,
			uimpreso              ,
			ufecha_emision        ,
			uprima_suscrita       ,
			uprima_retenida       ,
			ueliminada            ,
			usuma_aseg_adic       ,
			utipo_incendio        ,
			uprima_vida           ,
			uprima_vida_orig      ,
			ugastos               ,
			udoble_cob            ,
			udoble_cob_cia        ,
			udoble_cob_fecha      ,
			ucont_beneficios      ,
			ucod_doctor           ,
			ucambiar_tarifas      ,
			usubir_bo             
		  from emipouni
		  where cod_asegurado = a_cod_errado
	  	
		INSERT INTO temp_emipouni(
		    no_poliza            ,
			no_unidad            ,
			cod_ruta             ,
			cod_producto         ,
			cod_asegurado        ,
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
			activo               ,
			prima_asegurado      ,
			prima_total          ,
			no_activo_desde      ,
			facturado            ,
			user_no_activo       ,
			perd_total           ,
			impreso              ,
			fecha_emision        ,
			prima_suscrita       ,
			prima_retenida       ,
			eliminada            ,
			suma_aseg_adic       ,
			tipo_incendio        ,
			prima_vida           ,
			prima_vida_orig      ,
			gastos               ,
			doble_cob            ,
			doble_cob_cia        ,
			doble_cob_fecha      ,
			cont_beneficios      ,
			cod_doctor           ,
			cambiar_tarifas      ,
			subir_bo             
		  )
   VALUES(
		    uno_poliza            ,
			uno_unidad            ,
			ucod_ruta             ,
			ucod_producto         ,
			ucod_asegurado        ,
			usuma_asegurada       ,
			uprima                ,
			udescuento            ,
			urecargo              ,
			uprima_neta           ,
			uimpuesto             ,
			uprima_bruta          ,
			ureasegurada          ,
			uvigencia_inic        ,
			uvigencia_final       ,
			ubeneficio_max        ,
			udesc_unidad          ,
			uactivo               ,
			uprima_asegurado      ,
			uprima_total          ,
			uno_activo_desde      ,
			ufacturado            ,
			uuser_no_activo       ,
			uperd_total           ,
			uimpreso              ,
			ufecha_emision        ,
			uprima_suscrita       ,
			uprima_retenida       ,
			ueliminada            ,
			usuma_aseg_adic       ,
			utipo_incendio        ,
			uprima_vida           ,
			uprima_vida_orig      ,
			ugastos               ,
			udoble_cob            ,
			udoble_cob_cia        ,
			udoble_cob_fecha      ,
			ucont_beneficios      ,
			ucod_doctor           ,
			ucambiar_tarifas      ,
			usubir_bo             
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
