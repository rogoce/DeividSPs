-- Procedimiento que Realiza la insercion de la nva. requisicion a partir de la que se anulo

-- Creado    : 10/05/2006 - Autor: Armando Moreno M.
-- mod		 : 01/08/2006
-- mod       : 08/07/2009   Amado Perez -- Se agrego codigo para cuando son auto y soda
-- mod       : 16/11/2010	Amado Perez -- Se agrego codigo para cuando son requisiciones de origen "S" Devolucion de Primas
-- Amado en caso que haya algun cambio en este procedure se de replicar a este otro sp_che208

drop procedure sp_che229;
create procedure sp_che229(a_cod_agente char(5))
RETURNING char(10),char(20);

define _no_poliza char(10);
define _no_requis   char(10);
define _no_cheque,_no_cheque_ant,_cnt integer;
define _monto      dec(16,2);
define _n_cliente  char(50);
define _fecha_anulado,_fecha_impresion date;
define _no_documento     char(20);

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

foreach

	select distinct e.no_documento
	  into _no_documento
	  from emipomae e, emipoagt t
	 where e.no_poliza = t.no_poliza
	   and e.actualizado = 1
	   and t.cod_agente = a_cod_agente --'02264'
	   and e.cod_formapag = '006'
	   
    let _no_poliza = sp_sis21(_no_documento);
	
    update emipomae
	   set cod_formapag = '008',
	       cobra_poliza = 'C'
	 where no_poliza = _no_poliza;
	 
    update endedmae
	   set cod_formapag = '008'
	 where no_poliza = _no_poliza
	   and no_endoso = '00000';
	  
	  return _no_poliza,_no_documento with resume;
	       
end foreach

END
end procedure