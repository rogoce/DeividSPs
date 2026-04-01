-- Buscando las p0lizas de allied

-- Creado    : 25/04/2011 - Autor: Amado Perez M. 

drop procedure sp_sis152;

create procedure "informix".sp_sis152()
returning char(20),
          char(10),
		  char(5),
          date,
          date,
          smallint,
          char(5),
		  char(50),
          char(5),
		  char(50),
          dec(9,6);

define _no_poliza	 char(10);
define _no_documento char(20);
define _cod_contrato char(5);
define _cod_ruta     char(5);
define _vigencia_inic date;
define _vigencia_final date;
define _estatus_poliza smallint;
define _cantidad	smallint;
define _cod_endomov char(3);
define _no_factura2 char(10);
define _no_endoso	char(5);
define _monto       dec(16,2);
define _porc_partic_prima dec(9,6);
define _ruta        char(50);
define _contrato    char(50);
define _no_unidad   char(5);
define _no_cambio	smallint;


set isolation to dirty read;

foreach 
 select a.no_documento, a.no_poliza, a.vigencia_inic, a.vigencia_final, a.estatus_poliza, b.no_unidad, b.cod_ruta, b.cod_contrato, b.porc_partic_prima 
   into _no_documento, _no_poliza, _vigencia_inic, _vigencia_final, _estatus_poliza, _no_unidad, _cod_ruta, _cod_contrato, _porc_partic_prima  
   from emipomae a, emifacon b, emireaco c
  where a.no_poliza = b.no_poliza
    and a.actualizado = 1
	and a.no_documento = '1610-00462-01'
	and b.no_poliza = c.no_poliza
	and b.no_unidad = c.no_unidad
	and b.cod_contrato = c.cod_contrato
	and c.no_cambio = (select max(no_cambio) from emireama where no_poliza = b.no_poliza and no_unidad = b.no_unidad)
group by a.no_documento, a.no_poliza, a.vigencia_inic, a.vigencia_final, a.estatus_poliza, b.no_unidad, b.cod_ruta, b.cod_contrato, b.porc_partic_prima


{ select a.no_documento, a.no_poliza, a.vigencia_inic, a.vigencia_final, a.estatus_poliza, b.no_unidad, b.cod_ruta, b.cod_contrato, b.porc_partic_prima 
   into _no_documento, _no_poliza, _vigencia_inic, _vigencia_final, _estatus_poliza, _no_unidad, _cod_ruta, _cod_contrato, _porc_partic_prima  
   from emipomae a, emifacon b, emireaco c
  where a.no_poliza = b.no_poliza
    and a.actualizado = 1
--	and a.serie = 2011
--	and a.no_documento not in ('0207-00712-04', '0207-00905-01')
    and a.cod_ramo in ('002','020')
    and b.cod_ruta in ('00413','00412','00383','00382','00362','00360','00353','00338','00315','00334','00293','00271','00266')
	and b.no_poliza = c.no_poliza
	and b.no_unidad = c.no_unidad
	and b.cod_contrato = c.cod_contrato
	and c.no_cambio = (select max(no_cambio) from emireama where no_poliza = b.no_poliza and no_unidad = b.no_unidad)
group by a.no_documento, a.no_poliza, a.vigencia_inic, a.vigencia_final, a.estatus_poliza, b.no_unidad, b.cod_ruta, b.cod_contrato, b.porc_partic_prima
}
--having c.no_cambio = max(c.no_cambio)

--    and b.cod_ruta in ('00413','00412','00383','00382','00362','00360','00353','00338','00315','00334','00293','00271','00266')

 select tipo_contrato, nombre
   into _cantidad, _contrato
   from reacomae
  where cod_contrato = _cod_contrato;

  if _cantidad = 5 then
     select nombre
	   into _ruta
	   from rearumae
	  where cod_ruta = _cod_ruta;

     return _no_documento, _no_poliza, _no_unidad, _vigencia_inic, _vigencia_final, _estatus_poliza, _cod_ruta, _ruta, _cod_contrato, _contrato, _porc_partic_prima with resume;
  end if
  

end foreach

end procedure