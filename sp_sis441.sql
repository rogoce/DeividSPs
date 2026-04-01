-- Procedimiento para cambiar el uso del auto a comercial con valores suministrados por Jenniffer
--
-- Creado    : 04/04/2016 - Autor: Armanod Moreno M.


DROP PROCEDURE sp_sis441;

CREATE PROCEDURE "informix".sp_sis441()
RETURNING char(30),dec(16,2),dec(16,2),dec(16,2);

DEFINE _doc_remesa CHAR(30);
DEFINE _monto	   dec(16,2);
DEFINE _monto_aplicacion dec(16,2);
DEFINE _monto_act    	 dec(16,2);


foreach
	select doc_remesa,sum(monto)
	  into _doc_remesa,_monto
	  from cobredet c, remesasus r
	 where c.doc_remesa = r.doc_suspenso
	   and c.tipo_mov = 'E'
	   and c.actualizado = 1
	 group by 1
	 order by 2 desc

	let _monto_aplicacion = 0;
	let _monto_act        = 0;
	
    select sum(monto)
	  into _monto_aplicacion
	  from cobredet
	 where actualizado = 1
	   and doc_remesa  = _doc_remesa
	   and tipo_mov    = 'A';
	   
	if _monto_aplicacion is null then
		let _monto_aplicacion = 0;
	elif _monto_aplicacion < 0 then
		let _monto_aplicacion = _monto_aplicacion * -1;
    end if	
	   
	let _monto_act =  _monto - _monto_aplicacion;
	
	update cobsuspe
	   set monto = _monto_act
	 where doc_suspenso = _doc_remesa; 
	
	return _doc_remesa, _monto, _monto_aplicacion, _monto_act with resume;
	
end foreach

END PROCEDURE;