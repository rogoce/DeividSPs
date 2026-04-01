
DROP PROCEDURE sp_prom23;
CREATE PROCEDURE sp_prom23(a_numero1 integer, a_numero2 integer, a_opcion smallint)
RETURNING integer;
   
   define i, _valor1,_valor2 integer;
   -- Pulse 1 si desea imprimir el rango de Mayor a Menor
   -- Pulse 2 si desea imprimir el rango de Menor a Mayor

        if a_opcion = 2 then  --De menor a mayor
			let _valor1 = a_numero2;
			let _valor2 = a_numero1;
		else
			let _valor1 = a_numero1;
			let _valor2 = a_numero2;
		end if		
		for i = _valor1 to _valor2
			return i with resume;
		end for

END PROCEDURE
