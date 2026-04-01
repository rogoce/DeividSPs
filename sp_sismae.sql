-- Creado     : 1/10/2007 - Autor: Rub‚n Dar¡o Arn ez 
 DROP PROCEDURE sp_sismae;

create procedure "informix".sp_sismae(
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


-- Para cargar la tabla temporal de EMIPOMAE

define mno_poliza            char(10);
define mcod_compania         char(3);
define mcod_sucursal         char(3);
define msucursal_origen      char(3);
define mcod_grupo            char(5);
define mcod_perpago          char(3);
define mcod_tipocalc         char(3);
define mcod_ramo             char(3);
define mcod_subramo          char(3);
define mcod_formapag         char(3);
define mcod_tipoprod         char(3);
define mcod_contratante      char(10);
define mcod_pagador          char(10);
define mcod_no_renov         char(3);
define mserie                smallint;
define mno_documento         char(20);
define mno_factura           char(10);
define mprima                decimal(16,2);
define mdescuento            decimal(16,2);
define mrecargo              decimal(16,2);
define mprima_neta           decimal(16,2);
define mimpuesto             decimal(16,2);
define mprima_bruta          decimal(16,2);
define mprima_suscrita       decimal(16,2);
define mprima_retenida       decimal(16,2);
define mtiene_impuesto       smallint;
define mvigencia_inic        date;
define mvigencia_final       date;
define mfecha_suscripcion    date;
define mfecha_impresion      date;
define mfecha_cancelacion    date;
define mno_pagos             smallint;
define mimpreso              smallint;
define mnueva_renov          char(1);
define mestatus_poliza       smallint;
define mdirec_cobros         smallint;
define mpor_certificado      smallint;
define mactualizado          smallint;
define mdia_cobros1          smallint;
define mdia_cobros2          smallint;
define mfecha_primer_pago    date;
define mno_poliza_coaseg     char(30);
define mdate_changed         date;
define mrenovada             smallint;
define mdate_added           date;
define mperiodo              char(7);
define mcarta_aviso_canc     smallint;
define mcarta_prima_gan      smallint;
define mcarta_vencida_sal    smallint;
define mcarta_recorderis     smallint;
define mfecha_aviso_canc     date;
define mfecha_prima_gan      date;
define mfecha_vencida_sal    date;
define mfecha_recorderis     date;
define mcobra_poliza         char(1);
define muser_added           char(8);
define mult_no_endoso        integer;
define mdeclarativa          smallint;
define mabierta              smallint;
define mfecha_renov          date;
define mfecha_no_renov       date;
define mno_renovar           smallint;
define mperd_total           smallint;
define manos_pagador         smallint;
define msaldo_por_unidad     smallint;
define mfactor_vigencia      decimal(9,6);
define msuma_asegurada       decimal(16,2);
define mincobrable           smallint;
define msaldo                decimal(16,2);
define mfecha_ult_pago       date;
define mreemplaza_poliza     char(20);
define muser_no_renov        char(8);
define mposteado             char(1);
define mno_tarjeta           char(19);
define mfecha_exp            char(7);
define mcod_banco            char(3);
define mmonto_visa           decimal(16,2);
define mtipo_tarjeta         char(1);
define mno_recibo            char(10);
define mno_cuenta            char(17);
define mtipo_cuenta          char(1);
define mgestion              char(1);
define mfecha_gestion        date;
define mdia_cobro_anterior   smallint;
define mincentivo            smallint;
define mcod_origen           char(3);
define mcotizacion           char(10);
define mde_cotizacion        smallint;
define mpoliza_maestra       char(20);
define mfecha_entrega_aviso   date;
define mtiene_gastos         smallint;
define mgastos               decimal(16,2);
define mdoble_cobertura      smallint;
define mcia_doble_cob        char(3);
define mcontinuidad_benef    smallint;
define mcolectiva            char(1);
define mind_fecha_coti       datetime year to minute;
define mind_fecha_aprob      datetime year to minute;
define mind_fecha_emi        datetime year to minute;
define mind_fecha_ent        datetime year to minute;
define mlinea_rapida         smallint;
define msubir_bo             smallint;
define mleasing              smallint;
define mvisa_ren             smallint;

    
DEFINE _usuario       char(8);  -- 1
DEFINE _descripcion   char(30); -- 2
DEFINE _e_mail        char(30); -- 3 
DEFINE _status        char(1);  -- 4
DEFINE _windows_user  char(20); -- 5
DEFINE _fvac_out      date;	    -- 6
DEFINE _fvac_duein    date;	    -- 7

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE    temp_emipomae(
no_poliza            char(10),
cod_compania         char(3),
cod_sucursal         char(3),
sucursal_origen      char(3),
cod_grupo            char(5),
cod_perpago          char(3),
cod_tipocalc         char(3),
cod_ramo             char(3),
cod_subramo          char(3),
cod_formapag         char(3),
cod_tipoprod         char(3),
cod_contratante      char(10),
cod_pagador          char(10),
cod_no_renov         char(3),
serie                smallint,
no_documento         char(20),
no_factura           char(10),
prima                decimal(16,2),
descuento            decimal(16,2),
recargo              decimal(16,2),
prima_neta           decimal(16,2),
impuesto             decimal(16,2),
prima_bruta          decimal(16,2),
prima_suscrita       decimal(16,2),
prima_retenida       decimal(16,2),
tiene_impuesto       smallint,
vigencia_inic        date,
vigencia_final       date,
fecha_suscripcion    date,
fecha_impresion      date,
fecha_cancelacion    date,
no_pagos             smallint,
impreso              smallint,
nueva_renov          char(1),
estatus_poliza       smallint,
direc_cobros         smallint,
por_certificado      smallint,
actualizado          smallint,
dia_cobros1          smallint,
dia_cobros2          smallint,
fecha_primer_pago    date,
no_poliza_coaseg     char(30),
date_changed         date,
renovada             smallint,
date_added           date,
periodo              char(7),
carta_aviso_canc     smallint,
carta_prima_gan      smallint,
carta_vencida_sal    smallint,
carta_recorderis     smallint,
fecha_aviso_canc     date,
fecha_prima_gan      date,
fecha_vencida_sal    date,
fecha_recorderis     date,
cobra_poliza         char(1),
user_added           char(8),
ult_no_endoso        integer,
declarativa          smallint,
abierta              smallint,
fecha_renov          date,
fecha_no_renov       date,
no_renovar           smallint,
perd_total           smallint,
anos_pagador         smallint,
saldo_por_unidad     smallint,
factor_vigencia      decimal(9,6),
suma_asegurada       decimal(16,2),
incobrable           smallint,
saldo                decimal(16,2),
fecha_ult_pago       date,
reemplaza_poliza     char(20),
user_no_renov        char(8),
posteado             char(1),
no_tarjeta           char(19),
fecha_exp            char(7),
cod_banco            char(3),
monto_visa           decimal(16,2),
tipo_tarjeta         char(1),
no_recibo            char(10),
no_cuenta            char(17),
tipo_cuenta          char(1),
gestion              char(1),
fecha_gestion        date,
dia_cobro_anterior   smallint,
incentivo            smallint,
cod_origen           char(3),
cotizacion           char(10),
de_cotizacion        smallint,
poliza_maestra       char(20),
fecha_entrega_aviso   date,
tiene_gastos         smallint,
gastos               decimal(16,2),
doble_cobertura      smallint,
cia_doble_cob        char(3),
continuidad_benef    smallint,
colectiva            char(1),
ind_fecha_coti       datetime year to minute,
ind_fecha_aprob      datetime year to minute,
ind_fecha_emi        datetime year to minute,
ind_fecha_ent        datetime year to minute,
linea_rapida         smallint,
subir_bo             smallint,
leasing              smallint,
visa_ren             smallint
-- PRIMARY KEY		(cod_contratante)
	) WITH NO LOG;



-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
	  
	select	no_poliza            ,
			cod_compania         ,
			cod_sucursal         ,
			sucursal_origen      ,
			cod_grupo            ,
			cod_perpago          ,
			cod_tipocalc         ,
			cod_ramo             ,
			cod_subramo          ,
			cod_formapag         ,
			cod_tipoprod         ,
			cod_contratante      ,
			cod_pagador          ,
			cod_no_renov         ,
			serie                ,
			no_documento         ,
			no_factura           ,
			prima                ,
			descuento            ,
			recargo              ,
			prima_neta           ,
			impuesto             ,
			prima_bruta          ,
			prima_suscrita       ,
			prima_retenida       ,
			tiene_impuesto       ,
			vigencia_inic        ,
			vigencia_final       ,
			fecha_suscripcion    ,
			fecha_impresion      ,
			fecha_cancelacion    ,
			no_pagos             ,
			impreso              ,
			nueva_renov          ,
			estatus_poliza       ,
			direc_cobros         ,
			por_certificado      ,
			actualizado          ,
			dia_cobros1          ,
			dia_cobros2          ,
			fecha_primer_pago    ,
			no_poliza_coaseg     ,
			date_changed         ,
			renovada             ,
			date_added           ,
			periodo              ,
			carta_aviso_canc     ,
			carta_prima_gan      ,
			carta_vencida_sal    ,
			carta_recorderis     ,
			fecha_aviso_canc     ,
			fecha_prima_gan      ,
			fecha_vencida_sal    ,
			fecha_recorderis     ,
			cobra_poliza         ,
			user_added           ,
			ult_no_endoso        ,
			declarativa          ,
			abierta              ,
			fecha_renov          ,
			fecha_no_renov       ,
			no_renovar           ,
			perd_total           ,
			anos_pagador         ,
			saldo_por_unidad     ,
			factor_vigencia      ,
			suma_asegurada       ,
			incobrable           ,
			saldo                ,
			fecha_ult_pago       ,
			reemplaza_poliza     ,
			user_no_renov        ,
			posteado             ,
			no_tarjeta           ,
			fecha_exp            ,
			cod_banco            ,
			monto_visa           ,
			tipo_tarjeta         ,
			no_recibo            ,
			no_cuenta            ,
			tipo_cuenta          ,
			gestion              ,
			fecha_gestion        ,
			dia_cobro_anterior   ,
			incentivo            ,
			cod_origen           ,
			cotizacion           ,
			de_cotizacion        ,
			poliza_maestra       ,
			fecha_entrega_aviso  ,
			tiene_gastos         ,
			gastos               ,
			doble_cobertura      ,
			cia_doble_cob        ,
			continuidad_benef    ,
			colectiva            ,
			ind_fecha_coti       ,
			ind_fecha_aprob      ,
			ind_fecha_emi        ,
			ind_fecha_ent        ,
			linea_rapida         ,
			subir_bo             ,
			leasing              ,
			visa_ren             
			             
		into 
	     	mno_poliza            ,
			mcod_compania         ,
			mcod_sucursal         ,
			msucursal_origen      ,
			mcod_grupo            ,
			mcod_perpago          ,
			mcod_tipocalc         ,
			mcod_ramo             ,
			mcod_subramo          ,
			mcod_formapag         ,
			mcod_tipoprod         ,
			mcod_contratante      ,
			mcod_pagador          ,
			mcod_no_renov         ,
			mserie                ,
			mno_documento         ,
			mno_factura           ,
			mprima                ,
			mdescuento            ,
			mrecargo              ,
			mprima_neta           ,
			mimpuesto             ,
			mprima_bruta          ,
			mprima_suscrita       ,
			mprima_retenida       ,
			mtiene_impuesto       ,
			mvigencia_inic        ,
			mvigencia_final       ,
			mfecha_suscripcion    ,
			mfecha_impresion      ,
			mfecha_cancelacion    ,
			mno_pagos             ,
			mimpreso              ,
			mnueva_renov          ,
			mestatus_poliza       ,
			mdirec_cobros         ,
			mpor_certificado      ,
			mactualizado          ,
			mdia_cobros1          ,
			mdia_cobros2          ,
			mfecha_primer_pago    ,
			mno_poliza_coaseg     ,
			mdate_changed         ,
			mrenovada             ,
			mdate_added           ,
			mperiodo              ,
			mcarta_aviso_canc     ,
			mcarta_prima_gan      ,
			mcarta_vencida_sal    ,
			mcarta_recorderis     ,
			mfecha_aviso_canc     ,
			mfecha_prima_gan      ,
			mfecha_vencida_sal    ,
			mfecha_recorderis     ,
			mcobra_poliza         ,
			muser_added           ,
			mult_no_endoso        ,
			mdeclarativa          ,
			mabierta              ,
			mfecha_renov          ,
			mfecha_no_renov       ,
			mno_renovar           ,
			mperd_total           ,
			manos_pagador         ,
			msaldo_por_unidad     ,
			mfactor_vigencia      ,
			msuma_asegurada       ,
			mincobrable           ,
			msaldo                ,
			mfecha_ult_pago       ,
			mreemplaza_poliza     ,
			muser_no_renov        ,
			mposteado             ,
			mno_tarjeta           ,
			mfecha_exp            ,
			mcod_banco            ,
			mmonto_visa           ,
			mtipo_tarjeta         ,
			mno_recibo            ,
			mno_cuenta            ,
			mtipo_cuenta          ,
			mgestion              ,
			mfecha_gestion        ,
			mdia_cobro_anterior   ,
			mincentivo            ,
			mcod_origen           ,
			mcotizacion           ,
			mde_cotizacion        ,
			mpoliza_maestra       ,
			mfecha_entrega_aviso  ,
			mtiene_gastos         ,
			mgastos               ,
			mdoble_cobertura      ,
			mcia_doble_cob        ,
			mcontinuidad_benef    ,
			mcolectiva            ,
			mind_fecha_coti       ,
			mind_fecha_aprob      ,
			mind_fecha_emi        ,
			mind_fecha_ent        ,
			mlinea_rapida         ,
			msubir_bo             ,
			mleasing              ,
			mvisa_ren             
		  from  emipomae
		  where cod_contratante  = a_cod_errado
	  	
		INSERT INTO temp_emipomae(
		    no_poliza            ,
			cod_compania         ,
			cod_sucursal         ,
			sucursal_origen      ,
			cod_grupo            ,
			cod_perpago          ,
			cod_tipocalc         ,
			cod_ramo             ,
			cod_subramo          ,
			cod_formapag         ,
			cod_tipoprod         ,
			cod_contratante      ,
			cod_pagador          ,
			cod_no_renov         ,
			serie                ,
			no_documento         ,
			no_factura           ,
			prima                ,
			descuento            ,
			recargo              ,
			prima_neta           ,
			impuesto             ,
			prima_bruta          ,
			prima_suscrita       ,
			prima_retenida       ,
			tiene_impuesto       ,
			vigencia_inic        ,
			vigencia_final       ,
			fecha_suscripcion    ,
			fecha_impresion      ,
			fecha_cancelacion    ,
			no_pagos             ,
			impreso              ,
			nueva_renov          ,
			estatus_poliza       ,
			direc_cobros         ,
			por_certificado      ,
			actualizado          ,
			dia_cobros1          ,
			dia_cobros2          ,
			fecha_primer_pago    ,
			no_poliza_coaseg     ,
			date_changed         ,
			renovada             ,
			date_added           ,
			periodo              ,
			carta_aviso_canc     ,
			carta_prima_gan      ,
			carta_vencida_sal    ,
			carta_recorderis     ,
			fecha_aviso_canc     ,
			fecha_prima_gan      ,
			fecha_vencida_sal    ,
			fecha_recorderis     ,
			cobra_poliza         ,
			user_added           ,
			ult_no_endoso        ,
			declarativa          ,
			abierta              ,
			fecha_renov          ,
			fecha_no_renov       ,
			no_renovar           ,
			perd_total           ,
			anos_pagador         ,
			saldo_por_unidad     ,
			factor_vigencia      ,
			suma_asegurada       ,
			incobrable           ,
			saldo                ,
			fecha_ult_pago       ,
			reemplaza_poliza     ,
			user_no_renov        ,
			posteado             ,
			no_tarjeta           ,
			fecha_exp            ,
			cod_banco            ,
			monto_visa           ,
			tipo_tarjeta         ,
			no_recibo            ,
			no_cuenta            ,
			tipo_cuenta          ,
			gestion              ,
			fecha_gestion        ,
			dia_cobro_anterior   ,
			incentivo            ,
			cod_origen           ,
			cotizacion           ,
			de_cotizacion        ,
			poliza_maestra       ,
			fecha_entrega_aviso  ,
			tiene_gastos         ,
			gastos               ,
			doble_cobertura      ,
			cia_doble_cob        ,
			continuidad_benef    ,
			colectiva            ,
			ind_fecha_coti       ,
			ind_fecha_aprob      ,
			ind_fecha_emi        ,
			ind_fecha_ent        ,
			linea_rapida         ,
			subir_bo             ,
			leasing              ,
			visa_ren             
		  )
   VALUES(
		    mno_poliza            ,
			mcod_compania         ,
			mcod_sucursal         ,
			msucursal_origen      ,
			mcod_grupo            ,
			mcod_perpago          ,
			mcod_tipocalc         ,
			mcod_ramo             ,
			mcod_subramo          ,
			mcod_formapag         ,
			mcod_tipoprod         ,
			mcod_contratante      ,
			mcod_pagador          ,
			mcod_no_renov         ,
			mserie                ,
			mno_documento         ,
			mno_factura           ,
			mprima                ,
			mdescuento            ,
			mrecargo              ,
			mprima_neta           ,
			mimpuesto             ,
			mprima_bruta          ,
			mprima_suscrita       ,
			mprima_retenida       ,
			mtiene_impuesto       ,
			mvigencia_inic        ,
			mvigencia_final       ,
			mfecha_suscripcion    ,
			mfecha_impresion      ,
			mfecha_cancelacion    ,
			mno_pagos             ,
			mimpreso              ,
			mnueva_renov          ,
			mestatus_poliza       ,
			mdirec_cobros         ,
			mpor_certificado      ,
			mactualizado          ,
			mdia_cobros1          ,
			mdia_cobros2          ,
			mfecha_primer_pago    ,
			mno_poliza_coaseg     ,
			mdate_changed         ,
			mrenovada             ,
			mdate_added           ,
			mperiodo              ,
			mcarta_aviso_canc     ,
			mcarta_prima_gan      ,
			mcarta_vencida_sal    ,
			mcarta_recorderis     ,
			mfecha_aviso_canc     ,
			mfecha_prima_gan      ,
			mfecha_vencida_sal    ,
			mfecha_recorderis     ,
			mcobra_poliza         ,
			muser_added           ,
			mult_no_endoso        ,
			mdeclarativa          ,
			mabierta              ,
			mfecha_renov          ,
			mfecha_no_renov       ,
			mno_renovar           ,
			mperd_total           ,
			manos_pagador         ,
			msaldo_por_unidad     ,
			mfactor_vigencia      ,
			msuma_asegurada       ,
			mincobrable           ,
			msaldo                ,
			mfecha_ult_pago       ,
			mreemplaza_poliza     ,
			muser_no_renov        ,
			mposteado             ,
			mno_tarjeta           ,
			mfecha_exp            ,
			mcod_banco            ,
			mmonto_visa           ,
			mtipo_tarjeta         ,
			mno_recibo            ,
			mno_cuenta            ,
			mtipo_cuenta          ,
			mgestion              ,
			mfecha_gestion        ,
			mdia_cobro_anterior   ,
			mincentivo            ,
			mcod_origen           ,
			mcotizacion           ,
			mde_cotizacion        ,
			mpoliza_maestra       ,
			mfecha_entrega_aviso  ,
			mtiene_gastos         ,
			mgastos               ,
			mdoble_cobertura      ,
			mcia_doble_cob        ,
			mcontinuidad_benef    ,
			mcolectiva            ,
			mind_fecha_coti       ,
			mind_fecha_aprob      ,
			mind_fecha_emi        ,
			mind_fecha_ent        ,
			mlinea_rapida         ,
			msubir_bo             ,
			mleasing              ,
			mvisa_ren
		   );
end foreach;
return 0, "Actualizacion Exitosa";
			   
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
