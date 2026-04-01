--- Buscar manzana sin codigo
--- Armando Moreno Montenegro
--- 21/10/2008

drop procedure sp_pro846;

create procedure "informix".sp_pro846(v_poliza char(10),v_endoso char(5),v_opc integer)
RETURNING SMALLINT, 
		  CHAR(60);

BEGIN

DEFINE r_error,_act  SMALLINT;     
DEFINE r_descripcion CHAR(60);     
DEFINE _no_unidad    CHAR(5);      
DEFINE _cod_manzana  CHAR(5);


SET ISOLATION TO DIRTY READ;

LET r_error          = 0;   
LET r_descripcion    = NULL;

if v_opc = 2 then
	foreach

		Select cod_manzana,
		       no_unidad
		  Into _cod_manzana,
		       _no_unidad
		  From endeduni
		 Where no_poliza = v_poliza
		   And no_endoso = v_endoso

		if _cod_manzana is null or _cod_manzana = "" then
			let r_error = 1;
			let r_descripcion = "Es obligatorio el codigo de manzana para la unidad: " || _no_unidad;
			exit foreach;
		end if

	end foreach
elif v_opc = 2 then

	foreach

		Select cod_manzana,
		       no_unidad
		  Into _cod_manzana,
		       _no_unidad
		  From emipouni
		 Where no_poliza = v_poliza

		if _cod_manzana is null or _cod_manzana = "" then
			let r_error = 1;
			let r_descripcion = "Es obligatorio el codigo de manzana para la unidad: " || _no_unidad;
			exit foreach;
		end if

	end foreach

	Select actualizado
	  Into _act
	  From emipomae
	 Where no_poliza = v_poliza;

	if _act = 1 then
		let r_error = 0;
		let r_descripcion = "";
	end if

elif v_opc = 3 then
	foreach

		Select cod_manzana,
		       no_unidad
		  Into _cod_manzana,
		       _no_unidad
		  From emireaut
		 Where no_poliza = v_poliza

		if _cod_manzana is null or _cod_manzana = "" then
			let r_error = 1;
			let r_descripcion = "Es obligatorio el codigo de manzana para la unidad: " || _no_unidad;
			exit foreach;
		end if

	end foreach

end if

RETURN r_error, 
	   r_descripcion;
END

end procedure;
