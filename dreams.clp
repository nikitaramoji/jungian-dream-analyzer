(clear)
(set-reset-globals nil)
(reset)

(defglobal ?*analysis* = (str-cat "Here is your analysis: "))

/*
* Nikita Ramoji
* November 3rd, 2015
* The animal module attempts to guess an animal based on the user's yes or no responses
* to various identifying questions. The program provides a list of possible animals
* that can be guessed by the program, and will then prompt the user with various yes or 
* no questions until it can determine which animal the user had selected or has 
* run out of potential questions to be asked. The module currently does not always 
* terminate successfully after an animal has been guessed and may continue asking 
* questions. Furthermore, the module only accepts yes or no answers, and any other answers 
* will be evaluated as a no.
*/

/*
* ask (?prompt) will ask the user for their user input after printing out the 
* prompt entered as a String parameter. It will then return what the user inputted.
* The parameter ?prompt should be a String and can be used to indicate to the user
* what they should input. 
*/
(deffunction ask (?prompt)
   (printout t ?prompt crlf)
   
   (bind ?userInput (read))
   
   (return ?userInput)
)

/*
* askYesOrNoOnly (?prompt) will ask the user for their user input after printing out the 
* prompt entered as a String parameter. It will then return what the user inputted,
* as long as the user inputted either yes or no. If the input was not yes or no, 
* then the program will simply pretend that the answer was a no. 
* The parameter ?prompt should be a String and can be used to indicate to the user
* what they should input. 
*/
(deffunction askYesOrNoOnly (?prompt)
   (bind ?Input (ask ?prompt))
   
   (if (not (or (= 0 (str-compare ?Input yes)) (= 0 (str-compare ?Input no)))) then
   
      (printout t "Your answer wasn't a yes or no, so it will be evaluated as a no." crlf)
      (bind ?Input no)
   )   
   
   (return ?Input)
)


/* 
* NOT COMMENTED
* check for each option in the list whether it matches, and if it doesn't match with
* any of them then simply input the first option.
*/
(deffunction specificAsk (?prompt ?list)
   (bind ?goodResponse 0)
   (bind ?prompt (str-cat ?prompt "
The acceptable responses are: "))
  
   (foreach ?x ?list (bind ?prompt (str-cat ?prompt ?x " ")))
   
   (while (not (= 1 ?goodResponse)) do 
      (bind ?Input (ask ?prompt))
   
      (foreach ?x ?list 
         (if (= 0 (str-compare ?Input ?x)) then
            (bind ?goodResponse 1)
         )
      )
      
      (bind ?prompt "Please only enter responses from the previously given list.")
      
   )
      
   (return ?Input)
)


(deffunction askYesOrNoThenConcatIfYes (?prompt ?string)
   
   (bind ?Input (askYesOrNoOnly ?prompt))
   
   (if (= 0 (str-compare ?Input yes)) then
      (bind ?*analysis* (str-cat ?*analysis* ?string))
   )
   
   (return ?Input)
)


/*
* startup is the first rule and is guaranteed to fire once on the agenda system. The rule 
* gives a brief explanation as to the function and usage of the expert system, including
* the possible animals that can be guessed and the specification that the system only 
* accepts yes or no answers.
*/
(defrule startup
   (declare (salience 100))
   => 
   (printout t crlf "Expert System that Analyzes Dreams" crlf crlf)
   
   (printout t "Please only answer questions with either yes or no unless prompted otherwise." crlf)
   
   (printout t crlf "Answers that do not follow these guidelines will be taken as a no." crlf crlf)
   
   (bind ?question "What kind of dream did you have?
An anxiety dream bears an exact resemblance to something immediate in time, and
clearly relates to a problem you were worried about during the day.
An archetypal dream occurs in Kyros time and may appear more unrealistic." crlf)
   
   (bind ?Input (specificAsk ?question (create$ anxiety archetypal)))
   (assert (type ?Input))
    
)

(do-backward-chaining animal)
(do-backward-chaining bird)
(do-backward-chaining birdOfPrey)
(do-backward-chaining bugs)
(do-backward-chaining gender)
(do-backward-chaining snake)
(do-backward-chaining vulture)


(defrule need-animal "Check whether there were any animals within their dream."
   (type archetypal)
   (need-animal ?)
   =>
   (assert (animal (askYesOrNoThenConcatIfYes "Was there at an animal in your dream?" "
Animals have important symbolism within dreams.
Frequently, animals give a message that you may need to pay attention to the animalistic side of yourself.
")))

)

(defrule need-bugs "Check whether any bugs appeared in their dream."
   (type archetypal)
   (need-bugs ?)
   =>
   (assert (bugs (askYesOrNoThenConcatIfYes "Did any bugs appear in your dream?" "
Bugs often represent a connection with primal fears.
")))

)

(defrule need-snake "Check whether a snake appeared in their dream."
   (animal yes)
   (need-snake ?)
   =>
   (assert (snake (askYesOrNoThenConcatIfYes "Did a snake appear in your dream?" "
Snakes have notably potent symbolism within dreams.
")))
)

(defrule need-bird "Check whether the user noticed a bird in the dream."
   (animal yes)
   (need-bird ?)
   =>

   (assert (bird (askYesOrNoThenConcatIfYes "Did a bird appear in your dream?" "
The symbolism of the bird depends on the type of bird and the actions taken by the bird.
")))
   
)

(defrule need-birdOfPrey "Check whether the user noticed a bird of prey in the dream."
   (bird yes)
   (need-birdOfPrey ?)
   =>
   (assert (birdOfPrey (askYesOrNoThenConcatIfYes "Did a bird of prey come in the dream?""
In Greek mythology, birds of prey were seen as oracle birds and signs of good luck.
This idea originated because of the fact that birds of prey tend to have incredible
vision in order to swoop in and snatch their prey. Thus, birds of prey may symbolize
an insight into the future. 
")))

)

(defrule need-vulture "Check whether there was a vulture in the dream."
   (birdOfPrey yes)
   (need-vulture ?)
   =>
   (assert (vulture (askYesOrNoOnly "Was there a vulture in your dream?")))

)

(defrule need-gender "Check the user's gender."
   (type archetypal)
   (need-gender ?)
   =>
   (assert (gender (specificAsk "Are you male or female?" (create$ male female))))

)

(defrule anxiety "Check whether they had an anxiety dream."
   (type anxiety)
   =>
   (bind ?*analysis* "
You had an anxiety dream. This dream doesn't require analysis. 
However, it does signify that you could benefit from stress relief.")
)


(defrule pet "Check whether their pet appeared in their dream."
   (animal yes)
   =>

   (assert (pet (askYesOrNoThenConcatIfYes "Did your pet appear in your dream?" "
Pets can appear in dreams as protective spirits, warning of upcoming danger.
We often identify with our pets.
Sometimes your pet can change its shape or appearance as a sign as well.
")))

)

(defrule teethFallOut "Check whether any teeth fell out in their dream."
   (type archetypal)
   =>
   (assert (teethFallOut (askYesOrNoThenConcatIfYes "Did any teeth fall out?" "
Teeth falling out is a common symbol of change that can occur in dreams.
")))
   
)

(defrule death "Check whether there was a death in their dream."
   (type archetypal)
   =>
   (assert (death (askYesOrNoThenConcatIfYes "Was there a death in your dream?" "
Death symbolizes a significant change that has either already occurred or will occur
in your life. 
")))

)

(defrule cloggedToilet "Check whether there was a clogged toilet in their dream."
   (type archetypal)
   =>
   (assert (death (askYesOrNoThenConcatIfYes "Was there a clogged toilet in your dream?" "
A clogged toilet in a dream typically symbolizes that your emotions are blocked.
")))
   
)

(defrule pipes "Check for any overflowing pipes in their dream."
   (type archetypal)
   =>
   (assert (pipes (askYesOrNoThenConcatIfYes "Were there any overflowing pipes?" "
Overflowing plumbing often indicates that you are feeling overwhelmed by your emotions.
")))

)

(defrule eating "Check whether they were continuously eating in their dream."
   (type archetypal)
   =>
   (assert (eating (askYesOrNoThenConcatIfYes "Were you continuously eating?" "
Continuous eating–especially of chocolates, candies, and other unhealthy food–can 
be a warning sign that you are choosing instant gratification over giving yourself
what you truly need. 
"))) 

)

(defrule killBug "Check whether the user attempted to kill the bug(s) in the dream."
   (bugs yes)
   =>
    (assert (killBug (askYesOrNoThenConcatIfYes "Did you attempt to kill the bug(s)?" "
Attempting to kill a bug in a dream symbolizes an attempt to destroy a part of yourself.
In order to investigate this idea further, some analysts would recommend painting the 
insect in order to discover any hidden symbolism behind the image.
"))) 

)

(defrule ants "Check whether the user noticed ants the dream."
   (bugs yes)
   =>
    (assert (ants (askYesOrNoThenConcatIfYes "Did you notice any ants in your dream?" "
Ants are great workers and can denote the presence of a helpful figure in your life.
"))) 

)

(defrule beetle "Check whether the user noticed a beetle the dream."
   (bugs yes)
   =>
    (assert (beetle (askYesOrNoThenConcatIfYes "Did you notice a beetle in your dream?" "
Beetles symbolize the sun and power.
"))) 

)


(defrule crow "Check whether the user had a crow in the dream."
   (bird yes)
   =>
    (assert (crow (askYesOrNoThenConcatIfYes "Was there a crow in your dream?" "
Crows are incredibly intelligent animals, who can often communicate with humans.
Furthermore, the crow can sometimes be related to the Trickster archetype.
Many religions view the crow as a spirit animal, and its presence can be taken as a 
a symbol of inner reflection and support.
"))) 

)


(defrule owl "Check whether there was an owl in the dream."
   (birdOfPrey yes)
   =>
    (assert (owl (askYesOrNoThenConcatIfYes "Was there an owl in your dream?" "
Owls are the symbols of the goddess Athena in Greek mythology. 
Thus, they symbolize wisdom and the power of seeing into the darkness.
"))) 

)

(defrule vulturePos "Check whether the vulture was a positive symbol."
   (vulture yes)
   =>
   (assert (vulturePos (askYesOrNoThenConcatIfYes "Was the vulture a positive symbol?" "
If you saw the vulture as a positive symbol, then you can take its presence as a sign of 
power and energy. 
"))) 

)

(defrule vultureNeg "Check whether the vulture was a negative symbol in the dream."
   (vulturePos no) 
   =>
    (assert (vultureNeg (askYesOrNoThenConcatIfYes "Was the vulture a negative symbol?" "
If you saw the vulture as a negative symbol, then you can take its presence as a sign of 
cruelty, either by you or by another person in your life. 
"))) 

)

(defrule dove "Check whether there was a dove in the dream."
   (bird yes)
   =>
   (assert (dove (askYesOrNoThenConcatIfYes "Was there a dove in your dream?" "
Doves have notable symbolism according to Christianity. 
After the flood in the bible, Noah sent out a dove to see if there was land. 
Ever since, doves have been considered a symbol of rebirth.
Additionally, doves may represent a sense of peace and harmony.
"))) 

)

(defrule snakeMoveSilently "Check whether the snake moved silently in the dream."
   (snake yes)
   =>
   (assert (snakeMoveSilently (askYesOrNoThenConcatIfYes "Did the snake move silently?" "
The silent movement of the snake holds connotations of magic and power.
Also, the movement could symbolize a need for privacy or a desire to hide yourself.
"))) 

)

(defrule poisonousSnake "Check whether the snake was poisonous in the dream."
   (snake yes)
   =>
   (assert (poisonousSnake (askYesOrNoThenConcatIfYes "Was the snake poisonous?" "
The snake being poisonous foreshadows death and harm. 
"))) 
)

(defrule snakeShedSkin "Check whether the snake shed its skin in the dream."
   (snake yes)
   =>
   (assert (poisonousSnake (askYesOrNoThenConcatIfYes "Did the snake shed its skin?" "
The snake shedding its skin is a symbol of rebirth and change.
"))) 

)

(defrule lawEnforcer "Check whether there was a law enforcer figure in the dream."
   (type archetypal)
   =>
   (assert (lawEnforcer (askYesOrNoThenConcatIfYes "Was there a law enforcing figure?" "
The law enforcer is an archetypal figure. Most societies have figures whose jobs are
to enforce order, and most people's lives are highly regulated. People's fear of
breaking the rules and doing something wrong can come out in dreams through this figure.
"))) 

)

(defrule father "Check whether there was a fatherlike figure in the dream."
   (type archetypal)
   =>
   (assert (father (askYesOrNoThenConcatIfYes "Was there a fatherlike figure?" "
The Father is an archetypal figure. For Christians, the father image can be taken as the 
image of God, and this figure represents a connection with spirituality. If spirituality
is not grounded or one does not stay connected with their spiritual self, then
they may encounter problems in life.
"))) 

)


(defrule mother "Check whether there was a maternal figure in the dream?"
   (type archetypal)
   =>
   (assert (mother (askYesOrNoThenConcatIfYes "Was there a maternal figure?" "
Mothers represent the Great Mother archetypal figure. This figure is often associated with
birth, harvest and fertility. A mother appearing in a dream can also represent a 
sign of malnourishment, indicating that you are seeking for nourishment from a mother 
in the form of safety, love, and so on. The creation of a "mother" in a dream may be
a manifestation of that desire for nourishment.
"))) 

)

(defrule teacher "Check whether there was a teacher in the dream?"
   (type archetypal)
   =>
   (assert (teacher (askYesOrNoThenConcatIfYes "Was there a teacher in the dream?" "
The teacher is an archetypal figure of any age that you associate with teaching. Teachers
can be a guiding presence, leading you to whatever you feel that you need.
"))) 

)

(defrule sage "Check whether there was a sage in the dream?"
   (type archetypal)
   =>
   (assert (sage (askYesOrNoThenConcatIfYes "Was there a wise old man in the dream?" "
The wise old man represents the Sage archetypal figure and has wisdom to give you. 
"))) 

)

(defrule crone "Check whether there was a crone in the dream?"
   (type archetypal)
   =>
   (assert (sage (askYesOrNoThenConcatIfYes "Was there a wise old woman in the dream?" "
The wise old woman represents the Crone archetypal figure and has wisdom to give you. 
"))) 

)

(defrule books "Check whether there were any books in the dream?"
   (type archetypal)
   =>
   (assert (books (askYesOrNoThenConcatIfYes "Were there any books in the dream?" "
Books can be symbols of learning and often have positive energy in dreams.
"))) 

)


(defrule coyote "Check whether there was a coyote in the dream?"
   (animal yes)
   =>
   (assert (coyote (askYesOrNoThenConcatIfYes "Was there a coyote in the dream?" "
Coyotes are animalistic representations of the Trickster archetype in Native American
mythology. Coyotes are often considered sneaky characters and may be an example of
your subconscious trying to warn you that things are not as they appear. 
"))) 

)

(defrule mercury "Check whether there was any Mercury in the dream?"
   (type archetypal)
   =>
   (assert (mercury (askYesOrNoThenConcatIfYes "Was there any Mercury in the dream?" "
Mercury can represent the trickster archetypal figure because it has a quick-silver,
trickster quality about it. The appearance of Mercury may be an indication that something
in your life is not as it seems.
"))) 

)

(defrule trickster "Check whether there was a trickster figure in the dream?"
   (type archetypal)
   =>
   (assert (trickster (askYesOrNoThenConcatIfYes "Was there a trickster in the dream?" "
The trickster archetype is an example of the mind picking up on a slightly odd energy
in your life. However, not everything the trickster shows you is important, and 
the figure can also appear if you are being too serious and need to be more light-hearted.
"))) 

)

(defrule shadow "Check whether there was a shadow figure in the dream?"
   (type archetypal)
   =>
   (bind ?def "Was there a person of your gender who repulsed you in the dream?")
   (assert (shadow (askYesOrNoThenConcatIfYes ?def "
The Shadow is an archetypal figure that represents the un-lived parts of your personality.
Everyone is born with a 360˚ personality, but as we develop as children, society 
disciplines us to teach us what is acceptable or unacceptable. In dreams, people
project the side of themselves that they don't allow to manifest in waking life onto
another person, who typically shares their gender but repulses them. This figure
represents a part of you that you might want to acknowledge.
"))) 

)




/*
* This rule will only be fired after every other possible rule has been fired due
* to its low salience. The rule prints out onto the terminal that the game has ended
* and notifies the user that they need to batch the file in another time if he or she 
* wishes to play again. 

*/
(defrule end "Dream analysis has ended."
   (declare (salience -100))
   =>
   
   (printout t crlf ?*analysis* crlf "Dream analysis has ended." crlf
   "If you would like to analyze another dream, please batch in this file again." crlf)
)

(run) 
/* end of program */
