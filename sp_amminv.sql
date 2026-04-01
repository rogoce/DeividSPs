-- Informacion para SEMM

-- Creado    : 1O/07/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_amminv;

create procedure "informix".sp_amminv()
returning char(50),char(5),char(20),integer,char(10),char(100);

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_unidad       char(5);

define _cod_contratante char(10);
define _cod_subramo		char(3);
define _estatus      	smallint;

define _cod_cliente	char(10);
define _nombre			char(100);
define _cedula			char(30);

define _cantidad		integer;

{create temp table tmp_semm(
cedula			char(30),
nombre			char(100),
no_documento	char(20),
estatus			char(1)
) with no log;}

set isolation to dirty read;

let _cantidad = 0;


 select cod_cliente
   into _cod_cliente
   from cliclien
  where cod_cliente = "";


foreach

 select e.no_poliza,
        e.no_unidad
   into _no_poliza,
        _no_unidad
   from emipouni e, emipomae r
  where e.no_poliza = r.no_poliza
    and r.actualizado = 1
	and e.cod_asegurado = _cod_cliente
  order by e.no_poliza,e.no_unidad

 select no_documento,cod_contratante,estatus_poliza
   into _no_documento,_cod_contratante,_estatus
   from emipomae
  where actualizado = 1
    and	no_poliza   = _no_poliza;

  {if _estatus = 1 then
  else
    continue foreach;
  end if}

 select nombre
   into _nombre
   from cliclien
  where cod_cliente = _cod_contratante;

   return _no_poliza,_no_unidad,_no_documento,_estatus,_cod_contratante,_nombre with resume;


end foreach

end procedure							
