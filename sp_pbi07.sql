-- PBI 
-- Devuelve Información para la tabla dimPolizas y dimEstatusPolizas
-- Creado    : 27/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi07;
CREATE PROCEDURE sp_pbi07(a_fecha1 date, a_fecha2 date) 
RETURNING  char(20)    as Numero,
           char(10)    as NoPoliza,
		   date        as FechaDesde,
		   date        as FechaHasta,
		   char(5)     as CodGrupo,
           varchar(50) as NombreGrupo,
		   varchar(50) as TipoFormaPago,
		   varchar(50) as SucursalOrigen,
   		   varchar(25) as TipoProduccion,
		   varchar(50) as TipoNoRenov,
		   char(11)    as Estatus;
           
	DEFINE _no_poliza 			char(10);
    DEFINE _no_documento    	char(20);
    DEFINE _fecha_emision   	date;
    DEFINE _vigencia_inic_pol	date;
	DEFINE _vigencia_final_pol	date;
	DEFINE _cod_grupo 			char(5);
	DEFINE _FormaPago,_n_grupo,_n_sucursal,_n_norenov			varchar(50);
	DEFINE _nueva_renov         char(11);
	DEFINE _n_tipoprod          char(25);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi07.trc";	
  --trace on;

FOREACH
	select emi.no_documento,
           emi.no_poliza,
		   emi.vigencia_inic,
		   emi.vigencia_final,
           emi.cod_grupo,
           gru.nombre,
		   pag.nombre as FormaPago,
           ins.descripcion as sucursalorigen,
           tip.nombre as Tipo_produccion,
           ren.nombre as TipoNoRenov,
		   Case emi.estatus_poliza when 1 then "VIGENTE" when 2 then "CANCELADA" when 3 then "VENCIDA" when 4 then "ANULADA" end Estatus
	  into _no_documento,
		   _no_poliza,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _cod_grupo,
		   _n_grupo,
		   _FormaPago,
		   _n_sucursal,
		   _n_tipoprod,
		   _n_norenov,
		   _nueva_renov
  	  from emipomae emi
 	 inner join cligrupo gru
			 on emi.cod_grupo = gru.cod_grupo
     inner join insagen ins
			 on emi.sucursal_origen = ins.codigo_agencia
	 inner join cobforpa pag
			 on pag.cod_formapag = emi.cod_formapag
	 inner join emitipro tip
			 on emi.cod_tipoprod = tip.cod_tipoprod
	  left join eminoren ren
			 on emi.cod_no_renov = ren.cod_no_renov
	  where emi.actualizado = 1
        and emi.fecha_suscripcion between a_fecha1 and a_fecha2
	  order by emi.no_poliza
	  
	RETURN _no_documento,
	       _no_poliza,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _cod_grupo,
		   _n_grupo,
		   _FormaPago,
		   _n_sucursal,
		   _n_tipoprod,
		   _n_norenov,
		   _nueva_renov
		   WITH RESUME;		      
END FOREACH
END PROCEDURE	  