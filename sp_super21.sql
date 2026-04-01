   --Procedimiento que devuelve el pin de ciertas condiciones para data enviada a panama asitencia.
   --  Armando Moreno M. 10/08/2017
   
   DROP procedure sp_super21;
   CREATE procedure sp_super21(a_no_poliza char(10), a_no_unidad char(5))
   RETURNING char(4);
   
   DEFINE _no_poliza     CHAR(10);
   define _no_documento  char(20);
   DEFINE _poliza        CHAR(100);
   define _numrecla      char(18);
   define _no_motor      char(30);
   define _no_unidad     char(5);
   define _cod_asegurado char(10);
   define _n_asegurado   char(75);
   define _fecha_reclamo date;
   define _fecha_siniestro date;
   define _periodo		 char(7);
   define _n_tipoveh     char(30);
   define _cnt           integer;
   define _placa         char(10);
   define _cod_marca     char(5);
   define _cod_modelo    char(5);
   define _n_marca       char(50);
   define _n_modelo      char(50);
   define _pin   		 char(4);
   
SET ISOLATION TO DIRTY READ;
let _pin = '';
let _cnt = 0;
--Set Debug File To "sp_super21.trc";
--trace on;
--Automovil, limite mayor y que no tengan colision y vuelco pin es RC

select count(*)
  into _cnt
  from emipocob
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad
   and no_poliza in (select no_poliza
					  from emipocob
					 where no_poliza = a_no_poliza
					   and no_unidad = a_no_unidad
					   and cod_cobertura in (select cod_cobertura from prdcober where nombre like '%PROPIEDAD%')
					   and limite_1 > 5000)
  and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'LESIONES%')
  and limite_1 >= 5000 and limite_2 >= 10000
  and no_poliza not in (select no_poliza
					  from emipocob
					 where no_poliza = a_no_poliza
					   and no_unidad = a_no_unidad
					   and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'COLISI%'));
if _cnt > 0 then
	let _pin = "RC";
	return _pin;
end if

--Automovil, limite menor o igual y que no tengan colision y vuelco pin es S
select count(*)
  into _cnt
  from emipocob
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad
   and no_poliza in (select no_poliza
					  from emipocob
					 where no_poliza = a_no_poliza
					   and no_unidad = a_no_unidad
					   and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'PROPIEDAD%')
					   and limite_1 <= 5000)
  and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'LESIONES%')
  and limite_1 <= 5000 and limite_2 <= 10000
  and no_poliza not in (select no_poliza
					  from emipocob
					 where no_poliza = a_no_poliza
					   and no_unidad = a_no_unidad
					   and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'COLISI%'));

let _pin = '';
if _cnt > 0 then
	let _pin = "S";
end if
return _pin;
END PROCEDURE;