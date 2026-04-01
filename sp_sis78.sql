-- Rutina que retorna la Edad dado la fecha de nacimiento y a que fecha se desea saber la edad

-- Creado    : 03/06/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis78;
create procedure sp_sis78(_fecha_aniversario	date,_fecha_hoy	date	default today)
returning smallint;

define _edad smallint;

If Month( _fecha_aniversario ) <= Month(_fecha_hoy) THEN
	If Month( _fecha_aniversario ) = Month(_fecha_hoy) THEN
	  If Day(_fecha_aniversario ) <= Day(_fecha_hoy) THEN
	     LET _edad = year(_fecha_hoy) - year( _fecha_aniversario );
	  Else
	     LET _edad = (year(_fecha_hoy) - year( _fecha_aniversario )) - 1;
	  End If
	Else
	 LET _edad = (year(_fecha_hoy) - year(_fecha_aniversario));
	End If
Else
	LET _edad = (year(_fecha_hoy) - year(_fecha_aniversario)) - 1;
End If
return _edad;
end procedure