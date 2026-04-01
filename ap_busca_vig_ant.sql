-- 
-- Creado    : 05/08/2025 - Autor: Amado Perez

DROP PROCEDURE ap_busca_vig_ant;
CREATE PROCEDURE ap_busca_vig_ant() 
RETURNING  char(20) 	as NumeroPoliza,
           char(5) 		as no_unidad,
		   char(5) 		as CProducto,
		   varchar(50) 	as NProducto,
		   date 		as vigenciainicio,
		   date 		as vigenciafinal,
		   char(5) 		as CCobertura,
		   varchar(50) 	as NCobertura,
		   dec(16,2) 	as primaCOV,
		   dec(16,2) 	as DedCOV,
		   dec(16,2) 	as Suma,
		   smallint 	as ano_tarifa,
		   char(1) 		as OpcionDed,
		   smallint 	as Renovado;

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_endoso			char(5);
DEFINE 	_no_remesa			char(10);
DEFINE 	_renglon		    integer;
DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);
DEFINE  _no_documento       char(20);
DEFINE  _vigencia_inic      date;
DEFINE  _no_unidad          char(5);
DEFINE  _cod_producto		char(5);
DEFINE  _producto			varchar(50);
DEFINE  _vigencia_inic_ant	date;
DEFINE  _vigencia_final_ant	date;
DEFINE  _cod_cobertura		char(5);
DEFINE  _cobertura			varchar(50);
DEFINE  _prima				dec(16,2);
DEFINE  _deducible			dec(16,2);
DEFINE  _suma_asegurada		dec(16,2);
DEFINE  _ano_tarifa			smallint;
DEFINE  _opcion				char(1);
DEFINE  _renovada			smallint;



SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

--begin work;

begin
on exception set _error
--    rollback work;
	--return _error, "Error al Cambiar Tarifas...";
end exception


foreach 
	select distinct q.no_documento,
           q.vigencia_inic	
	  into _no_documento,
	       _vigencia_inic
	  from emipomae q
		inner join emipouni u on q.no_poliza = u.no_poliza
		inner join prdprod pro on u.cod_producto = pro.cod_producto
		inner join emipocob cob on u.no_poliza = cob.no_poliza and u.no_unidad = cob.no_unidad
		inner join prdcober c on cob.cod_cobertura = c.cod_cobertura
		inner join emiauto ea on u.no_poliza = ea.no_poliza and  u.no_unidad = ea.no_unidad
		where pro.cod_Ramo = '002'
		and pro.cod_subramo = '001'
		and q.vigencia_final between '01-07-2025' and '30-07-2026'
		and cob.cod_cobertura in ('00119','00121')
		and pro.cod_producto not in ('07213','03810','07215','03812','03811','02283','04132','02282','07627','07755','07754')
		and ea.opcion is NULL
		and pro.activo = 1
		and q.actualizado = 1
		and q.estatus_poliza = '1'
		and q.renovada = 0
	
	foreach
		select u.no_unidad, 
			   pro.cod_producto, 
			   pro.nombre,
			   p.vigencia_inic,
			   p.vigencia_final, 
			   cob.cod_cobertura, 
			   c.Nombre, 
			   cob.prima, 
			   cob.deducible,
			   u.suma_asegurada, 
			   ea.ano_tarifa, 
			   ea.opcion, 
			   p.renovada
	      into _no_unidad,
		       _cod_producto,
			   _producto,
			   _vigencia_inic_ant,
			   _vigencia_final_ant,
			   _cod_cobertura,
			   _cobertura,
			   _prima,
			   _deducible,
			   _suma_asegurada,
			   _ano_tarifa,
			   _opcion,
			   _renovada
		  from emipomae p
			inner join emipouni u on p.no_poliza = u.no_poliza
			inner join prdprod pro on u.cod_producto = pro.cod_producto
			inner join emipocob cob on u.no_poliza = cob.no_poliza and u.no_unidad = cob.no_unidad
			inner join prdcober c on cob.cod_cobertura = c.cod_cobertura
			inner join emiauto ea on u.no_poliza = ea.no_poliza and  u.no_unidad = ea.no_unidad
			where pro.cod_Ramo = '002'
			and pro.cod_subramo = '001'
			and cob.cod_cobertura in ('00119','00121')
		--	and pro.cod_producto not in ('07213','03810','07215','03812','03811','02283','04132','02282','07627','07755','07754')
			and p.actualizado = 1
			and p.no_documento = _no_documento
            and p.vigencia_final = _vigencia_inic			
			
	    return _no_documento,
   		       _no_unidad,
		       _cod_producto,
			   _producto,
			   _vigencia_inic_ant,
			   _vigencia_final_ant,
			   _cod_cobertura,
			   _cobertura,
			   _prima,
			   _deducible,
			   _suma_asegurada,
			   _ano_tarifa,
			   _opcion,
			   _renovada
               with resume;
	end foreach
end foreach
end

--commit work;
--return 0, 'Actualizacion exitosa';
END PROCEDURE	  