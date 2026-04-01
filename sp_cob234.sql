-- Aplicacion de Primas en Suspenso

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob234;

create procedure sp_cob234()
returning integer,
          char(100);

define _no_recibo		char(10);
define _no_recibo_otro	char(10);
define _doc_remesa		char(20);
define _no_rem_otr		char(10);
define _no_remesa		char(10);

define _mensaje			char(100);
 
foreach
 select	no_recibo,
        doc_remesa,
		no_remesa
   into _no_recibo,
        _doc_remesa,
		_no_remesa
   from cobredet
  where periodo     >= "2010-01"
    and actualizado = 1
	and tipo_mov    = "A"

   foreach	
   	select no_recibo,
		   no_remesa
   	  into _no_recibo_otro,
		   _no_rem_otr
   	  from cobredet
   	 where doc_remesa = _doc_remesa
   	   and tipo_mov   = 'E'
	 order by fecha	desc

		if _no_recibo <> _no_recibo_otro then
			let _mensaje = _doc_remesa[1,20] || " " || _no_recibo_otro[1,10] || " " || _no_rem_otr[1,10] || " " || _no_recibo[1,10] || " " || _no_remesa;
			return 1, _mensaje with resume;
		end if
		
		exit foreach;
			
   end foreach

end foreach

return 0, "Verificacion Completada";

end procedure 