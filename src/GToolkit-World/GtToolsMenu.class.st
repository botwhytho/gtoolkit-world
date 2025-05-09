Class {
	#name : #GtToolsMenu,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable',
	#classTraits : 'TBrLayoutResizable classTrait',
	#instVars : [
		'knowledgeBase'
	],
	#classInstVars : [
		'world'
	],
	#category : #'GToolkit-World-UI'
}

{ #category : #'system startup' }
GtToolsMenu class >> cleanUp [
	<script: 'self cleanUp'>

	world ifNotNil: [
		world isOpened
			ifTrue: [ world close ].
		world := nil ]
]

{ #category : #'instance creation' }
GtToolsMenu class >> create [
	| aSpace |
	
	aSpace := BlSpace new.
	aSpace title: 'Glamorous Toolkit'.
	aSpace addChild: self new.
	aSpace extent: 260@500.
	^ aSpace
]

{ #category : #'instance creation' }
GtToolsMenu class >> open [
	<script: 'self open'>

	(world isNotNil and: [ world isOpened ])
		ifTrue: [ world close ].

	world := self create.

	world isOpened
		ifFalse: [ world show ]
]

{ #category : #initialization }
GtToolsMenu >> addBottomButtons [
	self addChild: ((BlElement new)
				layout: (BlLinearLayout horizontal cellSpacing: 10);
				margin: (BlInsets
							top: 25
							left: 0
							bottom: 5
							right: 0);
				constraintsDo: 
						[:c |
						c horizontal matchParent.
						c vertical fitContent];
				addChildren: 
						{self saveButton.
						self renameButton.
						self quitButton})
]

{ #category : #initialization }
GtToolsMenu >> addSections [
	| homeToolsSection iconSize |

	homeToolsSection := GtHomeToolsSection new
		knowledgeBaseComputation: [self knowledgeBase].
	iconSize := self iconSize.

	self addChildren: (homeToolsSection allButtonStencils collect: [ :each |
		[ each smallIcon smallMargin create size: iconSize]
			on: Error
			do: [ :ex | (homeToolsSection handleButtonCreationException: ex) create size: iconSize ] ]).
	self children first requestFocus
]

{ #category : #deprecated }
GtToolsMenu >> dropDownAptitude: aBrGlamorousWithDropdownAptitude [ 
	"ignore"
]

{ #category : #initialization }
GtToolsMenu >> iconSize [
	^ 80 @ 80
]

{ #category : #initialization }
GtToolsMenu >> initialize [
	super initialize.
	
	self layout: BlFlowLayout new.
	self hMatchParent.
	self vFitContent.
	self padding: (BlInsets all: 10).
	self initializeElements
]

{ #category : #initialization }
GtToolsMenu >> initializeElements [
	self removeChildren.
	self addSections.
	self addBottomButtons
]

{ #category : #accessing }
GtToolsMenu >> knowledgeBase [
	^ knowledgeBase
]

{ #category : #accessing }
GtToolsMenu >> knowledgeBase: aKnowledgeBase [
	knowledgeBase := aKnowledgeBase
]

{ #category : #'hooks - children' }
GtToolsMenu >> onAddedToSceneGraph [
	super onAddedToSceneGraph.
	
	self initializeElements
]

{ #category : #initialization }
GtToolsMenu >> quitButton [
	^(BrButton new)
		aptitude: BrGlamorousButtonWithLabelAptitude + BrGlamorousToolsDropdownKeyboardFocusChangeAptitude;
		label: 'Quit';
		hMatchParent;
		action: [:aButton | self quitFrom: aButton]
]

{ #category : #'private - actions' }
GtToolsMenu >> quitFrom: aButton [
	aButton label: 'Quitting...'.
	aButton disable.
	aButton space universe snapshot: false andQuit: true.
	aButton space universe postpone: [
		aButton enqueueTask: (BlTaskAction new action: [
			aButton label: 'Quit'; enable ]) ].
]

{ #category : #initialization }
GtToolsMenu >> renameButton [
	| button |
	button := BrButton new.
	button
		aptitude: BrGlamorousButtonWithLabelAptitude + BrGlamorousToolsDropdownKeyboardFocusChangeAptitude
					+ (BrGlamorousWithExplicitDropdownAptitude handle: [
							(BrButton new)
								aptitude: BrGlamorousButtonRectangularAptitude
										+ BrGlamorousButtonLabelAptitude;
								label: 'Rename';
								hExact: button width;
								yourself]
							content: [self renameFrom: button]);
		label: 'Rename';
		hMatchParent.
	^button
]

{ #category : #'private (writing)' }
GtToolsMenu >> renameFrom: aButton [
	| container saveActionBlock |
	saveActionBlock :=
			[:aButtonRenameAction |
			aButton
				label: 'Renaming...';
				disable.
			aButtonRenameAction fireEvent: BrDropdownHideWish new.
			aButton
				enqueueTask: (BlTaskAction new action: 
							[| aFilename |
							aFilename := (aButtonRenameAction parent childWithId: #imageName) text
										asString.
							self renameImageTo: aFilename.
							aButton
								label: 'Rename';
								enable.
							aButton fireEvent: BrDropdownHideWish new ])].
	container := (BlElement new)
				layout: BlLinearLayout vertical;
				constraintsDo: 
						[:c |
						c horizontal exact: 250.
						c vertical fitContent];
				padding: (BlInsets all: 8);
				addChildren: 
						{(BrEditor new)
							aptitude: BrGlamorousEditorAptitude + BrGlamorousTextAreaSpacingAptitude;
							text: SmalltalkImage current imageFile basenameWithoutExtension;
							constraintsDo: [:c | c linear vertical alignCenter];
							id: #imageName.
						(BrButton new)
							aptitude: BrGlamorousButtonWithIconAptitude new;
							beSmallSize;
							constraintsDo: [:c | c linear vertical alignCenter];
							margin: (BlInsets top: 8);
							icon: BrGlamorousVectorIcons accept;
							action: saveActionBlock}.
	^container
]

{ #category : #'private (writing)' }
GtToolsMenu >> renameImageTo: aFilename [
	SmalltalkImage current saveAs: aFilename
]

{ #category : #initialization }
GtToolsMenu >> saveButton [
	^(BrButton new)
		aptitude: BrGlamorousButtonWithLabelAptitude + BrGlamorousToolsDropdownKeyboardFocusChangeAptitude;
		label: 'Save';
		hMatchParent;
		action: [:aButton | self saveFrom: aButton]
]

{ #category : #'private - actions' }
GtToolsMenu >> saveFrom: aButton [
	aButton label: 'Saving...'.
	aButton disable.
	aButton space universe snapshot: true andQuit: false.
	aButton space universe postpone: [
		aButton fireEvent: BrDropdownHideWish new.
		aButton enqueueTask: (BlTaskAction new action: [
			aButton label: 'Save'; enable ]) ].
]
