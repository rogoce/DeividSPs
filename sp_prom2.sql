
--DROP PROCEDURE sp_prom22;
CREATE PROCEDURE "informix".sp_prom22(a_numero smallint)
RETURNING char(100);
   
   define _cnt_cifras,_dm,_m,_d,_u,_c,_valor_c,_valor_d,_valor_dm,_valor_u,_valor_m integer;
   define _valor_char char(5);
   
   
   if a_numero >= 1 and a_numero <= 20000 then
   
		let _valor_char = a_numero;
		--let _cnt_cifras = length(a_numero);
		if _cnt_cifras = 5 then
			let _dm = _valor_char[1];
			let _valor_dm = _dm * 10000;
			let _m = _valor_char[2];
			let _valor_m = _m * 1000;
			let _c = _valor_char[3];
			let _valor_c = _c * 100;
			let _c = _valor_char[4];
			let _valor_d = _d * 10;
			let _u = _valor_char[5];
			let _valor_u = _u * 1;			
		end if
		return 'Decena Millar: ' || _valor_dm || ' Miles: ' || _valor_m || ' Cientos: ' || _valor_c || ' Decenas: ' ||_valor_d || ' Unidades: '|| _valor_u;
   else
		return 'Numero ingresado NO esta en el rango especificado.';
   end if
END PROCEDURE
