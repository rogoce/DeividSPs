-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS
-- Creado:	23/07/2014 - Autor: Amado Perez M
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_yos19; 
create procedure sp_yos19(a_fecha_desde date, a_fecha_hasta date)
returning	smallint, varchar(30);


define _no_motor	        char(50);
define _no_documento        char(20); 
define _no_poliza			char(10);
define _cod_modelo			char(5);
define _cod_tipo			char(3);
define _cod_ramo          	char(3);
define _descuento_max		dec(5,2);
define _tipo_descuento      smallint;
define _cant_g              smallint;
define _cant_p              smallint;
define _cant_s 				smallint;
define _tipo_auto			smallint;

set isolation to dirty read;

insert into emimarca(cod_marca,nombre,user_added,date_added,activo,tipo_exclusion,no_asegurar_web,requiere_aprob_tec,tiene_rec_ded,uso_web,code_pais)
select ys.cod_marca
		,ys.nombre
		,ys.user_added
		,ys.date_added
		,ys.activo
		,ys.tipo_exclusion
		,ys.no_asegurar_web
		,ys.requiere_aprob_tec
		,ys.tiene_rec_ded
		,ys.uso_web
		,272--,ys.code_pais
   from emimarca_ys ys
   left join emimarca mar on mar.cod_marca = ys.cod_marca
  where mar.cod_marca is null;

insert into emimodel(cod_modelo,cod_marca,cod_tipoauto,nombre,capacidad,user_added,date_added,activo,tipo_exclusion,tamano,porc_desc,porc_desc_feria,grupo)
select ys.cod_modelo,
	    ys.cod_marca,
		ys.cod_tipoauto,
		ys.nombre,
		ys.capacidad,
		ys.user_added,
		ys.date_added,
		ys.activo,
		ys.tipo_exclusion,
		ys.tamano,
		ys.porc_desc,
		ys.porc_desc_feria,
		ys.grupo
   from emimodel_ys ys
   left join emimodel mdl on mdl.cod_marca = ys.cod_marca and mdl.cod_modelo = ys.cod_modelo
  where mdl.cod_modelo is null;

return 0, "Insercion exitosa";

end procedure;