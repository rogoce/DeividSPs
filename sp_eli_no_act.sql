--procedimiento para eliminar de la tabla salud_ren_rec, registros que no de ben tener el aumento.
--30/07/2024
--execute procedure sp_eli_no_act('2993386','00123','00240')

DROP procedure sp_eli_no_act;
CREATE procedure sp_eli_no_act(a_no_poliza char(10),a_no_uni_desde char(5),a_no_uni_hasta char(5))
RETURNING char(10) as no_poliza,
          char(50) as mensaje;
		  

define _mensaje       char(50);
define _cnt smallint;

select count(*)
  into _cnt
  from emipomae
 where no_poliza = a_no_poliza
   and actualizado = 0;

if _cnt is null then let _cnt = 0;
end if

let _mensaje = 'Se eliminaron los registros.';
if _cnt > 0 then

	delete from emipocob
	where no_poliza = a_no_poliza
	  and no_unidad between a_no_uni_desde and a_no_uni_hasta;
	  
	delete from emipouni
	where no_poliza = a_no_poliza
	  and no_unidad between a_no_uni_desde and a_no_uni_hasta;
	  
	delete from emifacon
	where no_poliza = a_no_poliza
	  and no_endoso = '00000'
	  and no_unidad between a_no_uni_desde and a_no_uni_hasta;
else
		let _mensaje = "no_Poliza esta actualizado, no se puede eliminar.";
end if

return a_no_poliza,_mensaje;

END PROCEDURE;
