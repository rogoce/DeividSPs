
DROP PROCEDURE sp_prom1;
CREATE PROCEDURE "informix".sp_prom1(a_numero smallint)
RETURNING char(70), smallint;
   
   define _valor,_cnt,i integer;
   
   let _cnt = 0;
   let _valor = 0;
   
   if a_numero > 10 then
		for i = 1 to a_numero
			let _valor = mod(i, 2);
			if _valor = 0 then
				if i > 10 then
					let _cnt = _cnt + 1;
				end if
			end if
		end for
   else
		return 'Numero ingresado es menor a 10, no aplica.',a_numero;
   end if
   
   RETURN 'Numero '|| a_numero || ' tiene ' || _cnt || ' numeros pares mayores a 10',0;
END PROCEDURE
