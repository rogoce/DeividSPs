-- Procedimiento que la informacion de las primas por producto para armar el presupuesto
-- 
-- Creado     : 02/10/2012 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pre01ley2;		

create procedure "informix".sp_pre01ley2(a_periodo1 char(7), a_periodo2 char(7))
returning char(3),
		  char(50),
		  char(10),
		  char(5),
		  char(50),
		  char(50),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _periodo1		char(7);
define _periodo2		char(7);
define _periodo			char(7);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_producto	char(5);
define _nombre_producto	char(50);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _vigencia_inic	date;
define _vigencia_final	date;

define _cantidad		smallint;
define _mes,_cnt		smallint;

define _no_registro		char(10);

define _octubre			dec(16,2);
define _noviembre		dec(16,2);
define _diciembre		dec(16,2);
define _enero			dec(16,2);
define _febrero			dec(16,2);
define _marzo			dec(16,2);
define _abril			dec(16,2);
define _mayo			dec(16,2);
define _junio			dec(16,2);
define _julio			dec(16,2);
define _agosto			dec(16,2);
define _septiembre		dec(16,2);

define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _prima_cedida	dec(16,2);
define _monto_prima		dec(16,2);

define _nueva_renov		char(1);
define _nueva_renov_d	char(10);
define _tipo_prima		char(1);
define _tipo_prima_d	char(10);
define _suc_origen      char(3);
define _desc_agen       char(50);
define _producto_presup char(5);
define i                smallint;
define _cod_subramo     char(3);
define _cod_grupo       char(5);

set isolation to dirty read;

create temp table tmp_prod (
cod_ramo		char(3),
cod_producto	char(5),
nueva_renov		char(1),
tipo_prima		char(1),
mes				smallint,
prima			dec(16,2) default 0,
suc_origen 		char(3),
primary key (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, suc_origen)
) with no log;


-- Crea la Estructura de los Productos

foreach
 select p.cod_ramo,
		p.sucursal_origen,
        u.cod_producto
   into _cod_ramo,
        _suc_origen,
        _cod_producto
   from endedmae e, emipomae p, endeduni u
  where e.no_poliza = p.no_poliza
    and e.no_poliza = u.no_poliza
	and e.no_endoso = u.no_endoso
    and e.periodo    >= a_periodo1
    and e.periodo    <= a_periodo2
	and e.actualizado = 1
  group by 1, 2, 3
  order by 1, 2, 3

  let _producto_presup = null;

  select producto_presup
    into _producto_presup
	from prdprod
   where cod_producto = _cod_producto;
   
  if _producto_presup is null then
  	let _producto_presup = _cod_producto;
  end if

  let _cod_producto = _producto_presup;

    select count(*)
	  into _cnt
	  from tmp_prod
	 where cod_ramo     = _cod_ramo 
	   and cod_producto = _cod_producto
	   and suc_origen   = _suc_origen;

	if _cnt > 0 then
		continue foreach;
	end if

	for _mes = 1 to 12

		insert into tmp_prod (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, prima,suc_origen) 
		values (_cod_ramo, _cod_producto, "N", "S", _mes, 0,_suc_origen);

		insert into tmp_prod (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, prima,suc_origen) 
		values (_cod_ramo, _cod_producto, "N", "C", _mes, 0,_suc_origen);

		insert into tmp_prod (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, prima,suc_origen) 
		values (_cod_ramo, _cod_producto, "R", "S", _mes, 0,_suc_origen);

		insert into tmp_prod (cod_ramo, cod_producto, nueva_renov, tipo_prima, mes, prima,suc_origen) 
		values (_cod_ramo, _cod_producto, "R", "C", _mes, 0,_suc_origen);

	end for

end foreach


--drop table tmp_prod;

end procedure