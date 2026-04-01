-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas.
--
-- creado    : 28/08/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure ap_clasificado;
create procedure "informix".ap_clasificado()
returning   integer,
			char(100);   -- _error

define _deducible_char	varchar(50);
define _deduc_char		varchar(50);
define _error_desc		char(100);
define _cod_cobertura	char(5);
define _cod_subramo		char(3);
define _cod_ramo		char(3);
define _char			char(1);
define _deducible		dec(16,2);
define _limite1   		dec(16,2);
define _limite2		   	dec(16,2);
define _prima		   	dec(16,2);
define _error_isam		smallint;
define _tipo_cober		smallint;
define _len_valor		smallint;
define _cant_char		smallint;
define _error			smallint;

begin work;

begin
on exception set _error,_error_isam,_error_desc
    rollback work;
 	return _error,_error_desc;
end exception

set isolation to dirty read;

--ACTUALIZAR BMW SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00010'
and t.tipo_auto = 1 );

--ACTUALIZAR BMW CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00010'
and t.tipo_auto = 2 );

--ACTUALIZAR MERCEDES SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00091'
and t.tipo_auto = 1 );

--ACTUALIZAR MERCEDES CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00091'
and t.tipo_auto = 2 );

--ACTUALIZAR FERRARI SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00464'
and t.tipo_auto = 1 );

--ACTUALIZAR LEXUS SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00080'
and t.tipo_auto = 1 );

--ACTUALIZAR LEXUS CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00080'
and t.tipo_auto = 2 );

--ACTUALIZAR PORSCHE SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00108'
and t.tipo_auto = 1 );

--ACTUALIZAR PORSCHE CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00108'
and t.tipo_auto = 2 );

--ACTUALIZAR MASERATI SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00390'
and t.tipo_auto = 1 );

--ACTUALIZAR LAMBORGHINI SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00470'
and t.tipo_auto = 1 );


--ACTUALIZAR JAGUAR SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00063'
and t.tipo_auto = 1 );

--ACTUALIZAR JAGUAR CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00063'
and t.tipo_auto = 2 );

--ACTUALIZAR AUDI SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00208'
and t.tipo_auto = 1 );

--ACTUALIZAR AUDI CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00208'
and t.tipo_auto = 2 );

--ACTUALIZAR BENTLEY SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00408'
and t.tipo_auto = 1 );

--ACTUALIZAR BENTLEY CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00408'
and t.tipo_auto = 2 );

--ACTUALIZAR ACURA SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00356'
and t.tipo_auto = 1 );

--ACTUALIZAR ACURA CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00356'
and t.tipo_auto = 2 );

--ACTUALIZAR LINCOLN SEDAN
update emimodel
set grupo = 'SED0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00312'
and t.tipo_auto = 1 );

--ACTUALIZAR LINCOLN CAMIONETA
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca = '00312'
and t.tipo_auto = 2 );
--*******************
--**este es para elantra y eon que son de la misma marca
update emimodel
set grupo = 'SED1'
where cod_modelo in('01545','10240','08908');

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SENTRA%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'COROLLA%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'VERSA%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'PICANTO%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'CIVIC%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'CELERIO%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'AVEO%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'MARCH%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'CITY%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'CIAZ%'
and e.cod_marca = '00120'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'ACCORD%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'ACCENT%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'YARIS%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'TIIDA%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'ALMERA%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SWIFT%'
and e.cod_marca = '00120'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'LANCER%'
and e.cod_marca = '00096'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'RIO%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'CERATO%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'ALTO%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SPARK%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'I10%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'SED3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'I-20%'
and t.tipo_auto = 1 );

update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'LAND CRUISER%'
and e.cod_marca = '00122'
and t.tipo_auto = 2 );

--********************** las marcas land rover y range rover
update emimodel
set grupo = 'CAM0'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.cod_marca in('00588','00786')
and t.tipo_auto = 2);

--***********************************
update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'RAV 4%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'X%TRAIL%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'QASHQAI%'
and t.tipo_auto = 2 );

--********modelo fortuner
update emimodel
set grupo = 'CAM1'
where cod_modelo in('03574');

update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'GRAND%VITARA%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'PILOT%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'EDGE%'
and e.cod_marca = '00031'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'NATIVA%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'TUCSON%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'CRV%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SANTA FE%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'EXPLORER%'
and e.cod_marca = '00031'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'OUTLANDER%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SPORTAGE%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'ERTIGA%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'PATHFINDER%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SORENTO%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'ASX%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'CAM3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'JIMNY%'
and e.cod_marca = '00120'
and t.tipo_auto = 2 );


update emimodel
set grupo = 'CAM3'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'SOUL%'
and t.tipo_auto = 2 );

update emimodel
set grupo = 'PICK1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like '%HI%LUX%'
and e.cod_marca = '00122'
and t.tipo_auto = 3 );

update emimodel
set grupo = 'PICK1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'NAVARA%'
and t.tipo_auto = 3 );

update emimodel
set grupo = 'PICK1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'AMAROK%'
and t.tipo_auto = 3 );

update emimodel
set grupo = 'PICK1'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'FRONTIER%'
and t.tipo_auto = 3 );

update emimodel
set grupo = 'PICK2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like '%D%MAX%'
and t.tipo_auto = 3 );

update emimodel
set grupo = 'PICK2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like '%L%200%'
and e.cod_marca = '00096'
and t.tipo_auto = 3 );

update emimodel
set grupo = 'PICK2'
where cod_modelo in(select e.cod_modelo from emimodel e, emiautip t, emitiaut a
where e.cod_tipoauto = a.cod_tipoauto
and a.tipo_auto = t.tipo_auto
and e.nombre like 'RANGER%'
and e.cod_marca = '00031'
and t.tipo_auto = 3 );

end

commit work;
return 0, 'actualizacion exitosa';
end procedure

